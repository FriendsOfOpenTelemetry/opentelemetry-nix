{ pkgs }:

let
  
  mkConfigurationFile = {
      name,
      go,
      settings
  }: let
    jsonFile = pkgs.writeTextFile {
      name = "${name}-configuration-builder.json";
      text = builtins.toJSON ({
        dist = {
          inherit name;
          go ="${go}/bin/go";
          output_path = "output";
        };
      } // settings);
    };
    in pkgs.runCommand "${name}-configuration-builder.yaml" {
      nativeBuildInputs = [ pkgs.remarshal ];
    } ''
      ${pkgs.remarshal}/bin/remarshal ${jsonFile} --of yaml > $out
    '';
  buildOtelCollector = {
      name,
      version,
      vendorHash,
      settings,
      builder ? pkgs.otel-collector-builder,
      go ? pkgs.go
  }@finalAttrs: pkgs.stdenv.mkDerivation rec {
    pname = name;
    inherit version;

    nativeRuntimeInputs = [ builder ];

    src = mkConfigurationFile {
      inherit name go settings;
    };

    dontUnpack = true;

    configurePhase = ''
      runHook preConfigure

      export GOCACHE=$TMPDIR/go-cache
      export GOPATH="$TMPDIR/go"

      runHook postConfigure
    '';

    buildPhase = ''
      runHook preBuild

      export PATH="${go}/bin:$PATH" 

      ${pkgs.lib.getExe builder} --config=${src}

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      cp -r output/${name} $out/bin

      runHook postInstall
    '';

    passthru = {
      configurationFile = src;
    };

    outputHashMode = "recursive";
    outputHashAlgo = if (finalAttrs ? vendorHash && finalAttrs.vendorHash != "") then null else "sha256";
    outputHash = finalAttrs.vendorHash or "";
  };
in {
  inherit buildOtelCollector mkConfigurationFile;
}