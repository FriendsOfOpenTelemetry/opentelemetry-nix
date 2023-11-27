# OpenTelemetry for Nix

[![.github/workflows/ci.yml](https://github.com/FriendsOfOpenTelemetry/opentelemetry-nix/actions/workflows/ci.yml/badge.svg)](https://github.com/FriendsOfOpenTelemetry/opentelemetry-nix/actions/workflows/ci.yml)
[![flakestry.dev](https://flakestry.dev/api/badge/flake/github/FriendsOfOpenTelemetry/opentelemetry-nix)](https://flakestry.dev/flake/github/FriendsOfOpenTelemetry/opentelemetry-nix)
[![FlakeHub](https://img.shields.io/endpoint?url=https://flakehub.com/f/FriendsOfOpenTelemetry/opentelemetry-nix/badge)](https://flakehub.com/flake/FriendsOfOpenTelemetry/opentelemetry-nix)

> This repository exposes various OpenTelemetry related packages and a library to build custom OpenTelemetry collectors

## Packages

- [otel-collector-builder](https://github.com/open-telemetry/opentelemetry-collector/tree/main/cmd/builder)
- [otel-desktop-viewer](https://github.com/open-telemetry/opentelemetry-collector/tree/main/cmd/builder)

## Library

- `buildOtelCollector`: build a custom OpenTelemetry collector
- `mkOtelCollectorBuilderConfiguration`: create an OpenTelemetry collector builder configuration file

## Usage

TBD
