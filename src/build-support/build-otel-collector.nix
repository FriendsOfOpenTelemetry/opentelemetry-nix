{
  lib,
  stdenv,
  mkOtelCollectorBuilderConfiguration,
  installShellFiles,
  opentelemetry-collector-builder,
}:

{
  name ? args'.pname,
  vendorHash ? (throw "builOtelCollector: vendorHash is missing"),
  otelBuilderPackage ? opentelemetry-collector-builder,
  meta ? { },
  ...
}@args':
let
  args = removeAttrs args' [ "vendorHash" ];
  otelCollectorBuilderConfiguration = mkOtelCollectorBuilderConfiguration (
    args // { goPackage = otelBuilderPackage.go; }
  );
  otelCollectorBuilderModules = stdenv.mkDerivation {
    pname = "${name}-modules";
    inherit (args') version;
    src = otelCollectorBuilderConfiguration;

    nativeBuildInputs = [
      otelBuilderPackage
      otelBuilderPackage.go
    ];

    dontUnpack = true;

    configurePhase = ''
      runHook preConfigure

      export GOCACHE=$TMPDIR/go-cache
      export GOPATH="$TMPDIR/go"

      runHook postConfigure
    '';

    buildPhase = ''
      runHook preBuild

      mkdir -p "''${GOPATH}/pkg/mod/cache/download"

      mkdir -p output
      ${lib.getExe otelBuilderPackage} \
        --config=${otelCollectorBuilderConfiguration} \
        --skip-compilation

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      rm -rf "''${GOPATH}/pkg/mod/cache/download/sumdb"
      cp -r --reflink=auto "''${GOPATH}/pkg/mod/cache/download" $out
      cp -r --reflink=auto output $out/output

      runHook postInstall
    '';

    dontFixup = true;

    outputHashMode = "recursive";
    outputHash = vendorHash;
    outputHashAlgo = if (vendorHash != "") then null else "sha256";
  };
in
stdenv.mkDerivation {
  pname = name;
  inherit (args') version;

  src = otelCollectorBuilderConfiguration;

  dontUnpack = true;

  nativeBuildInputs = [
    otelBuilderPackage
    otelBuilderPackage.go
    installShellFiles
  ];

  configurePhase = ''
    runHook preConfigure

    export GOCACHE=$TMPDIR/go-cache
    export GOPATH="$TMPDIR/go"
    export GOSUMDB=off
    export GOPROXY=file://${otelCollectorBuilderModules}

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    cp -r ${otelCollectorBuilderModules}/output output

    cd output && go install -ldflags="-s -w"

    runHook postBuild
  '';

  # TODO: In checkPhase, parse ouput of `build components` to assert presence of exporters, receivers & processors

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    dir="$GOPATH/bin"
    [ -e "$dir" ] && cp $dir/builder $out/bin/${name}

    runHook postInstall
  '';

  postInstall = ''
    installShellCompletion --cmd ${name} \
    --bash <($out/bin/${name} completion bash) \
    --fish <($out/bin/${name} completion fish) \
    --zsh <($out/bin/${name} completion zsh)
  '';

  passthru = {
    inherit
      otelBuilderPackage
      otelCollectorBuilderConfiguration
      otelCollectorBuilderModules
      vendorHash
      ;
  };

  meta = {
    platforms = otelBuilderPackage.go.meta.platforms or lib.platforms.all;
  } // meta;
}
