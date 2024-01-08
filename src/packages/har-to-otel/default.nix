{ lib
, python3
, python3Packages
, fetchFromGitHub
, substituteAll
}:

python3Packages.buildPythonApplication rec {
  pname = "har-to-otel";
  version = "0.9.0";
  format = "setuptools";

  disabled = python3.pythonOlder "3.11";

  src = fetchFromGitHub {
    owner = "agardnerIT";
    repo = "tracepusher";
    rev = "668053739ee93556f6a121bf0f047514379c4596";
    hash = "sha256-w+xrp2uHoXZQv4YzM1Kmiv2KSlM0iHh1n8OlgUcq0OQ=";
  };

  patches = [ ./shebang.patch ];

  postPatch = let
    setup = substituteAll {
      src = ./setup.py;
      desc = meta.description;
      inherit pname version;
    };
  in ''
    ln -s ${setup} setup.py
  '';

  propagatedBuildInputs = [
    python3Packages.requests
  ];

  doCheck = false;

  meta = with lib; {
    changelog = "https://github.com/agardnerIT/tracepusher/releases/tag/${version}";
    description = "Chrome DevTools HAR File to OpenTelemetry Converter";
    homepage = "https://github.com/agardnerIT/tracepusher/tree/main/har-to-otel";
    license = licenses.asl20;
    maintainers = with maintainers; [ gaelreyrol ];
    mainProgrom = "har-to-otel.py";
  };
}