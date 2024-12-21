{
  lib,
  buildNpmPackage,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  nodejs_20,
}:

let
  pname = "tracetest";
  version = "1.7.1";
  src = fetchFromGitHub {
    owner = "kubeshop";
    repo = "tracetest";
    tag = "v${version}";
    hash = "sha256-Y/H8L4PysJjCGyE7Q++jpUAS5K/+Uxk4/rZ4RHVO+ig=";
  };
  ui = buildNpmPackage {
    inherit pname version src;

    sourceRoot = "source/web";

    patches = [ ./package-lock.patch ];

    nodejs = nodejs_20;

    npmDepsHash = "sha256-mWRU//M/UDrXrFCNI1actvNM/vuk4T9KdzlZCKoEXZ4=";
    npmPackFlags = [ "--ignore-scripts" ];

    env.CYPRESS_INSTALL_BINARY = 0;

    installPhase = ''
      runHook preInstall

      cp -r build $out

      runHook postInstall
    '';
  };
in
buildGoModule rec {
  inherit pname version src;

  # Fixes https://github.com/grafana/godeltaprof/issues/4
  patches = [ ./go.sum.patch ];

  vendorHash = "sha256-y+OHaoEtBYSyYZTfEc3Eo8r1tVSuqrL7omJQo6MtfDs=";

  nativeBuildInputs = [ installShellFiles ];

  subPackages = [
    "cli"
    "server"
  ];

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/kubeshop/tracetest/server/version.Version=${version}"
  ];

  preBuild = ''
    cp -r ${ui} web/build
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp $GOPATH/bin/cli $out/bin/tracetest
    cp $GOPATH/bin/server $out/bin/tracetest-server

    runHook postInstall
  '';

  postInstall = ''
    installShellCompletion --cmd tracetest \
      --bash <($out/bin/tracetest completion bash) \
      --fish <($out/bin/tracetest completion fish) \
      --zsh <($out/bin/tracetest completion zsh)

    installShellCompletion --cmd tracetest-server \
      --bash <($out/bin/tracetest-server completion bash) \
      --fish <($out/bin/tracetest-server completion fish) \
      --zsh <($out/bin/tracetest-server completion zsh)
  '';

  doCheck = false;

  passthru = {
    inherit ui;
  };

  meta = with lib; {
    changelog = "https://github.com/kubeshop/tracetest/releases/tag/v${version}";
    description = "Build integration and end-to-end tests in minutes using OpenTelemetry and trace-based testing";
    homepage = "https://github.com/kubeshop/tracetest";
    license = licenses.mit;
    mainProgram = "tracetest";
    maintainers = with maintainers; [ gaelreyrol ];
  };
}
