{ lib
, buildNpmPackage
, fetchYarnDeps
, buildGoModule
, fetchFromGitHub
, systemd
, makeWrapper
, installShellFiles
}:

{
  enableBoringCrypto ? false # https://grafana.com/docs/agent/latest/about/#boringcrypto
}: let
  pname = "grafana-agent";
  version = "0.38.1";
  src = fetchFromGitHub {
    owner = "grafana";
    repo = "agent";
    rev = "v${version}";
    hash = "sha256-caqJE92yEzqU/UQS7Cgxe+4+wGqBqPshhhPAyPP2WPQ=";
  };
  ui = buildNpmPackage {
    inherit pname version src;

    sourceRoot = "source/web/ui";

    patches = [ ./package-lock-json.patch ];

    npmDepsHash = "sha256-02WpeMAH12catR9sxo6hPZgNtdgEWwp0wF0YquUZ/rE=";

    npmPackFlags = [ "--ignore-scripts" ];

    npmFlags = [ "--legacy-peer-deps" ];
    
    makeCacheWritable = true;

    NODE_OPTIONS = "--openssl-legacy-provider";

    env.CYPRESS_INSTALL_BINARY = 0;

    installPhase = ''
      runHook preInstall

      cp -r build $out

      runHook postInstall
    '';
  };
in buildGoModule {
  inherit pname version src;

  nativeBuildInputs = [ systemd.dev makeWrapper installShellFiles ];

  subPackages = [ "cmd/grafana-agentctl" "cmd/grafana-agent" "cmd/grafana-agent-flow" ];

  vendorHash = "sha256-XIJkgUYwhiFc34vLhvwCyjrb3vB6A8IeFJ23vvPEZNc=";

  env = {
    GOEXPERIMENT = lib.optionalString enableBoringCrypto "boringcrypto";
    CGO_CFLAGS = "-I${systemd.dev}/include";
  };

  ldflags = [
    "-s"
    "-w"
    "-X github.com/grafana/agent/pkg/build.Branch=${src.rev}"
    "-X github.com/grafana/agent/pkg/build.Version=${version}"
    "-X github.com/grafana/agent/pkg/build.Revision=${src.rev}"
    "-X github.com/grafana/agent/pkg/build.BuildUser=github:FriendsOfOpenTelemetry/opentelemetry-nix"
    "-X github.com/grafana/agent/pkg/build.BuildDate=now"
  ];

  tags = [ "netgo" "builtinassets" "promtail_journal_enabled" ];

  preBuild = ''
    cp -r ${ui} web/ui/build
  '';

  postInstall = ''
    installShellCompletion --cmd grafana-agentctl \
      --bash <($out/bin/grafana-agentctl completion bash) \
      --fish <($out/bin/grafana-agentctl completion fish) \
      --zsh <($out/bin/grafana-agentctl completion zsh)

    installShellCompletion --cmd grafana-agent \
      --bash <($out/bin/grafana-agent completion bash) \
      --fish <($out/bin/grafana-agent completion fish) \
      --zsh <($out/bin/grafana-agent completion zsh)

      installShellCompletion --cmd grafana-agent-flow \
      --bash <($out/bin/grafana-agent-flow completion bash) \
      --fish <($out/bin/grafana-agent-flow completion fish) \
      --zsh <($out/bin/grafana-agent-flow completion zsh)
  '';

  doCheck = false;

  passthru = {
    inherit ui;
  };

  meta = with lib; {
    description = "Vendor-neutral programmable observability pipelines";
    homepage = "https://github.com/grafana/agent";
    changelog = "https://github.com/grafana/agent/blob/${src.rev}/CHANGELOG.md";
    license = licenses.asl20;
    mainProgram = "grafana-agent";
    maintainers = with maintainers; [ gaelreyrol ];
  };
}
