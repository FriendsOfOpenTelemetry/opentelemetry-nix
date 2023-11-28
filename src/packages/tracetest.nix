{ lib
, buildNpmPackage
, buildGoModule
, fetchFromGitHub
}:

let
  pname = "tracetest";
  version = "0.14.7";
  src = fetchFromGitHub {
    owner = "kubeshop";
    repo = "tracetest";
    rev = "v${version}";
    hash = "sha256-9D4HUSbybMmerB5tXqQAwNXk+uaktrt0PJVlA5x0BYg=";
  };
  ui = buildNpmPackage {
    inherit pname version src;

    sourceRoot = "source/web";

    npmDepsHash = "sha256-CiF71pWlUwAE/sZQh3NcC4sF36vNifV0YrsCteBIO2s=";

    npmPackFlags = [ "--ignore-scripts" ];

    env.CYPRESS_INSTALL_BINARY = 0;

    installPhase = ''
      runHook preInstall

      cp -r build $out

      runHook postInstall
    '';
  };
in buildGoModule rec {
  inherit pname version src;

  vendorHash = "sha256-6ojTDKA5XgOzmNHWID8lwH/07O0PC5wNNsCfTBZquEI=";

  subPackages = [ "cli" "server" ];

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/kubeshop/tracetest/server/version.Version=${version}"
  ];

  preBuild = ''
    cp -r ${ui} web/build
  '';

  doCheck = false;

  passthru = {
    inherit ui;
  };

  meta = with lib; {
    changelog = "https://github.com/kubeshop/tracetest/releases/tag/v${version}";
    description = "Tracetest - Build integration and end-to-end tests in minutes, instead of days, using OpenTelemetry and trace-based testing";
    homepage = "https://github.com/kubeshop/tracetest";
    license = licenses.mit;
    mainProgram = "tracetest";
    maintainers = with maintainers; [ gaelreyrol ];
  };
}
