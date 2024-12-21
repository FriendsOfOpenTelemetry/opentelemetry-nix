{
  lib,
  python3,
  python3Packages,
  fetchFromGitHub,
  substituteAll,
}:

python3Packages.buildPythonApplication rec {
  pname = "har-to-otel";
  version = "0.10.0";
  format = "setuptools";

  disabled = python3.pythonOlder "3.11";

  src = fetchFromGitHub {
    owner = "agardnerIT";
    repo = "tracepusher";
    rev = version;
    hash = "sha256-QxisvPLn62WuTHF1592Q5b5w4W0GskgknrKctgNcmFk=";
  };

  patches = [ ./shebang.patch ];

  postPatch =
    let
      setup = substituteAll {
        src = ./setup.py;
        desc = meta.description;
        inherit pname version;
      };
    in
    ''
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
    mainProgram = "har-to-otel.py";
  };
}
