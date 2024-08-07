{ lib
, buildNpmPackage
, buildGoModule
, fetchFromGitHub
, installShellFiles
}:

let
  pname = "tracetest";
  version = "0.16.1";
  src = fetchFromGitHub {
    owner = "kubeshop";
    repo = "tracetest";
    rev = "v${version}";
    hash = "sha256-3YzCq3mOcF42dzxhkkk7089Xv1BmwHODbDkEhs1aAmk=";
  };
  ui = buildNpmPackage {
    inherit pname version src;

    sourceRoot = "source/web";

    patches = [ ./package-lock.patch ];

    npmDepsHash = "sha256-ktEYoaakYyxj6uwkFwwAiY4faw5K91GaxvPs8v2n7TA=";

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

  vendorHash = "sha256-QzdrqNtQQJ/aOTOFsagvlOxGS5wzZOvulLNhPXbYjnY=";

  nativeBuildInputs = [ installShellFiles ];

  subPackages = [ "cli" "server" ];

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
