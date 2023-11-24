{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "otel-desktop-viewer";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "CtrlSpice";
    repo = "otel-desktop-viewer";
    rev = "v${version}";
    hash = "sha256-kMgcco4X7X9WoCCH8iZz5qGr/1dWPSeQOpruTSUnonI=";
  };

  subPackages = [ "..." ];

  vendorHash = "sha256-pH16DCYeW8mdnkkRi0zqioovZu9slVc3gAdhMYu2y98=";

  ldflags = [ "-s" "-w" ];

  meta = with lib; {
    changelog = "https://github.com/CtrlSpice/otel-desktop-viewer/releases/tag/v${version}";
    description = "Desktop-collector";
    homepage = "https://github.com/CtrlSpice/otel-desktop-viewer";
    license = licenses.asl20;
    maintainers = with maintainers; [ gaelreyrol ];
    mainProgram = "otel-desktop-viewer";
  };
}
