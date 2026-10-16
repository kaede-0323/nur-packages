{
  lib,
  buildNimPackage,
  fetchFromGitHub,
  libx11,
  libxrandr,
  libGL,
  libxext,
  ...
}:
buildNimPackage {
  pname = "boomer";
  version = "unstable-2026-09-15";
  src = fetchFromGitHub {
    owner = "tsoding";
    repo = "boomer";
    rev = "97189f7ef07859a86420ef11258ca29527774d9c";
    hash = "sha256-GxrPoDU1vj0SGuji/vinRu7WThY/J7LTdIdrOG4WOwo=";
  };
  buildInputs = [
    libx11
    libxrandr
    libGL
    libxext
  ];
  nimbleFile = "boomer.nimble";
  lockFile = ./lock.json;
  nimFlags = [
    "-d:mitshm"
  ];

  # INFO: See https://github.com/tsoding/boomer/issues/26#issuecomment-1820374229
  patchPhase = ''
    find . -type f -name "*.nim" -exec sed -i 's/TXShmSegmentInfo/PXShmSegmentInfo/g' {} +
  '';

  meta = with lib; {
    description = "Zoomer application for Linux";
    homepage = "https://github.com/tsoding/boomer";
    license = licenses.mit;
    mainProgram = "boomer";
  };
}
