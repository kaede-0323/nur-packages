{
  lib,
  clangStdenv,
  fetchFromGitHub,
  pkg-config,
  makeWrapper,
  freetype,
  libx11,
  libxext,
  libxfixes,
  libGL,
  zenity,
  xdg-utils,
}:
clangStdenv.mkDerivation (finalAttrs: {
  pname = "raddebugger";
  version = "0.9.29-alpha";

  src = fetchFromGitHub {
    owner = "EpicGames";
    repo = "raddebugger";
    rev = "cd41ba199bbe091d348a9b2be5a3528cb8acbff0";
    hash = "sha256-IQNicRWKdIamDeQU1RRceRR2QgoUlomQYoeCgepO10w=";
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    freetype
    libx11
    libxext
    libxfixes
    libGL
  ];

  # build.sh asks git for the commit id, which the fetched tarball cannot answer
  postPatch = ''
    patchShebangs build.sh
    substituteInPlace build.sh \
      --replace-fail '$(git describe --always --dirty)' '${lib.substring 0 8 finalAttrs.src.rev}' \
      --replace-fail '$(git rev-parse HEAD)' '${finalAttrs.src.rev}'
  '';

  # A bare `release` argument selects no target at this tag, so name it explicitly
  buildPhase = ''
    runHook preBuild
    ./build.sh raddbg release clang
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 build/raddbg $out/bin/raddbg
    runHook postInstall
  '';

  # zenity backs the message boxes and file picker, xdg-open the browser and file manager hand-offs
  postFixup = ''
    wrapProgram $out/bin/raddbg --suffix PATH : ${lib.makeBinPath [zenity xdg-utils]}
  '';

  meta = {
    description = "Native graphical debugger from Epic Games Tools";
    homepage = "https://github.com/EpicGames/raddebugger";
    license = lib.licenses.mit;
    mainProgram = "raddbg";
    platforms = ["x86_64-linux"];
  };
})
