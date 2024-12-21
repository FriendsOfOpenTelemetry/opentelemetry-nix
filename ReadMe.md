# OpenTelemetry for Nix

[![.github/workflows/build.yml](https://github.com/FriendsOfOpenTelemetry/opentelemetry-nix/actions/workflows/build.yml/badge.svg)](https://github.com/FriendsOfOpenTelemetry/opentelemetry-nix/actions/workflows/build.yml)
[![.github/workflows/check.yml](https://github.com/FriendsOfOpenTelemetry/opentelemetry-nix/actions/workflows/check.yml/badge.svg)](https://github.com/FriendsOfOpenTelemetry/opentelemetry-nix/actions/workflows/check.yml)

[![flakestry.dev](https://flakestry.dev/api/badge/flake/github/FriendsOfOpenTelemetry/opentelemetry-nix)](https://flakestry.dev/flake/github/FriendsOfOpenTelemetry/opentelemetry-nix)
[![FlakeHub](https://img.shields.io/endpoint?url=https://flakehub.com/f/FriendsOfOpenTelemetry/opentelemetry-nix/badge)](https://flakehub.com/flake/FriendsOfOpenTelemetry/opentelemetry-nix)

> This repository exposes various OpenTelemetry related packages and a library to build custom OpenTelemetry collectors

## Packages

- [tracetest](https://github.com/kubeshop/tracetest) - Build integration and end-to-end tests in minutes using OpenTelemetry and trace-based testing
- [tracepusher](https://github.com/agardnerIT/tracepusher) - Generate and push OpenTelemetry Trace data to an OTEL collector in JSON format 
- [har-to-otel](https://github.com/agardnerIT/tracepusher/tree/main/har-to-otel) - Chrome DevTools HAR file to OpenTelemetry converter

## Library

- `buildOtelCollector`: build a custom OpenTelemetry collector
- `mkOtelCollectorBuilderConfiguration`: create an OpenTelemetry collector builder configuration file

## Usage

This repository uses Nix "flake" feature and does not provider other usages. Please refer to the [documentation](https://nixos.org/manual/nix/unstable/contributing/experimental-features.html?highlight=enable#xp-feature-flakes) to enable it.

Each package is exposed as an application, you can run each one of them with `nix run`:

```bash
nix run github:FriendsOfOpenTelemtry/opentelemetry-nix#otel-collector-builder
nix run github:FriendsOfOpenTelemtry/opentelemetry-nix#{package-name}
```

Please refer to the [nix run](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-run) documentation for wider use.

Those packages are also available in an overlay.

### Flake

Import the repository as input:

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  opentelemetry-nix.url = "github:FriendsOfOpenTelemetry/opentelemetry-nix";
};
```

Import the overlay:

```nix
pkgs = import inputs.nixpkgs {
  inherit system;
  overlays = [
    inputs.opentelemetry-nix.overlays.default
  ];
};
```

Use the packages:

```nix
# for example in a devShell:
devShells.x86_64-linux.default = pkgs.mkShell {
  packages = [ pkgs.otel-collector-builder ];
}
```

#### Library

##### `buildOtelCollector`: Build a custom OpenTelemetry collector

```nix
# for example as a package:
packages.x86_64-linux.default = pkgs.buildOtelCollector {
  pname = "otel-collector-debugexporter";
  version = "1.0.0";
  config = {
    exporters = [
      { gomod = "go.opentelemetry.io/collector/exporter/debugexporter v0.115.0"; }
    ];
  };
  vendorHash = "sha256-sq3T9bOWDeJMZD9+LE4nPc9fqF3tkEaGEy4dJ/qgkgA=";
}
```

###### Options

- `pname`: The package name.
- `version`: The package version.
- `config`: The configuration that will be passed to `mkOtelCollectorBuilderConfiguration`. It must match the exact YAML representation of the configuration options mentionned in the builder [documentation](https://github.com/open-telemetry/opentelemetry-collector/tree/main/cmd/builder#configuration) for `extensions, exporters, receivers, processors & replaces` options.
- `vendorHash`: The hash of the custom collector sources & modules.
- `otelBuilderPackage`: The OpenTelemetry collector builder package to use, defaults the one available in this flake.
- `meta`: The meta attributes to use to describe the custom OpenTelemetry collector package.

##### `mkOtelCollectorBuilderConfiguration`: Create an OpenTelemetry collector builder configuration file

```nix
# for example as a package:
packages.x86_64-linux.default = pkgs.mkOtelCollectorBuilderConfiguration {
  pname = "otel-collector-debugexporter";
  version = "1.0.0";
  config = {
    exporters = [
      { gomod = "go.opentelemetry.io/collector/exporter/debugexporter v0.115.0"; }
    ];
  };
}
```

###### Options

- `pname`: The configuration name.
- `version`: The configuration version.
- `config`: The configuration to use. It must match the exact YAML representation of the configuration options mentionned in the builder [documentation](https://github.com/open-telemetry/opentelemetry-collector/tree/main/cmd/builder#configuration) for `extensions, exporters, receivers, processors & replaces` options.
- `goPackage`: The go package to use when building the generated configuration file with the OpenTelemetry collector builder.

## Cachix

Cachix is used to store package binaries. 

To use our cache, run `cachix use opentelemetry`.

Refer to the [documentation](https://docs.cachix.org/) to install Cachix.