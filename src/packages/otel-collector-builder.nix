{ lib
, buildGoModule
, fetchFromGitHub
, makeWrapper
, installShellFiles
, go
}:

buildGoModule rec {
  pname = "otel-collector-builder";
  version = "0.92.0";

  src = fetchFromGitHub {
    owner = "open-telemetry";
    repo = "opentelemetry-collector";
    rev = "v${version}";
    hash = "sha256-4hvnvRBow5H4x8zvPNEFxx8bvRzZy+aQxCqmihIZ13A=";
  };

  sourceRoot = "source/cmd/builder";

  vendorHash = "sha256-nASmx+z2V2QgHCo1Wi+4Lf5lBev8Nk9bHwfkLib/5UY=";

  nativeBuildInputs = [ makeWrapper installShellFiles ];

  allowGoReference = false;

  ldflags = [
    "-s"
    "-w"
    "-X go.opentelemetry.io/collector/cmd/builder/internal.version=${version}"
    "-X go.opentelemetry.io/collector/cmd/builder/internal.date=now"
  ];

  CGO_ENABLED = 0;

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

  # GenerateAndCompile test run `go get`.
  checkFlags = [ "-skip=TestGenerateAndCompile" ];

  passthru = {
    inherit version go;
  };

  meta = with lib; {
    changelog = "https://github.com/open-telemetry/opentelemetry-collector/releases/tag/cmd/builder/v${version}";
    description = "Generates a custom OpenTelemetry Collector binary based on a given configuration";
    homepage = "https://github.com/open-telemetry/opentelemetry-collector/tree/main/cmd/builder";
    license = licenses.asl20;
    mainProgram = "ocb";
    maintainers = with maintainers; [ gaelreyrol ];
  };
}
