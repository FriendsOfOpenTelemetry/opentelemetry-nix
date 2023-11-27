{ lib
, buildGoModule
, fetchFromGitHub
, makeWrapper
, installShellFiles
, go
}:

buildGoModule rec {
  pname = "otel-collector-builder";
  version = "0.89.0";

  src = fetchFromGitHub {
    owner = "open-telemetry";
    repo = "opentelemetry-collector";
    rev = "v${version}";
    hash = "sha256-SICpGj8sk24Y07Vn5gWO8QGvc/4PnG7rBVq/i5tR0vg=";
  };

  sourceRoot = "source/cmd/builder";

  vendorHash = "sha256-qhX5qwb/NRG8Tf2z048U6a8XysI2bJlUtUF+hfBtx4Q=";

  nativeBuildInputs = [ makeWrapper installShellFiles ];

  allowGoReference = false;

  ldflags = [
    "-s"
    "-w"
    "-X go.opentelemetry.io/collector/cmd/builder/internal.version=${version}"
    "-X go.opentelemetry.io/collector/cmd/builder/internal.date=now"
  ];

  CGO_ENABLED = 0;

  doCheck = false;

  installPhase = ''
    runHook preInstall
  
    mkdir -p $out/bin
    cp $GOPATH/bin/builder $out/bin/ocb
    # wrapProgram $out/bin/ocb \
    # --prefix PATH : ${lib.makeBinPath [ go ]}

    runHook postInstall
  '';

  postInstall = ''
    installShellCompletion --cmd ocb \
    --bash <($out/bin/ocb completion bash) \
    --fish <($out/bin/ocb completion fish) \
    --zsh <($out/bin/ocb completion zsh)
  '';

  passthru = {
    inherit version go;
  };

  meta = with lib; {
    description = "Generates a custom OpenTelemetry Collector binary based on a given configuration";
    changelog = "https://github.com/open-telemetry/opentelemetry-collector/releases/tag/cmd/builder/v${version}";
    homepage = "https://github.com/open-telemetry/opentelemetry-collector/tree/main/cmd/builder";
    license = licenses.asl20;
    mainProgram = "ocb";
    maintainers = with maintainers; [ gaelreyrol ];
  };
}
