{
  lib,
  buildNimPackage,
  fetchFromGitHub,
  libx11,
  ...
}:
buildNimPackage (finalAttrs: {
  pname = "yaim";
  version = "1.1.1";
  src = fetchFromGitHub {
    owner = "kaede-0323";
    repo = "${finalAttrs.pname}";
    rev = "1526d2499ee99e8d8a7a83f043b15cabac3c399a";
    hash = "sha256-LRhXb+70sn2U/wANBVLRisVxYsAD3QVCy+kvPK7s4lc=";
  };
  buildInputs = [libx11];
  nimbleFile = "yaim.nimble";
  lockFile = ./lock.json;
  nimFlags = [
    "-d:release"
    "-d:danger"
    "--panics"
  ];

  meta = with lib; {
    description = "yaim (Yet Another make IMage)";
    homepage = "https://github.com/kaede-0323/${finalAttrs.pname}";
    license = licenses.mit;
    mainProgram = "yaim";
  };
})
