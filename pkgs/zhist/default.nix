{
  lib,
  buildGoModule,
  fetchFromGitHub,
  fzf,
  makeWrapper,
}:
buildGoModule (finalAttrs: {
  pname = "zhist";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "overflowy";
    repo = "zhist";
    rev = "v${finalAttrs.version}";
    hash = "sha256-94XdxL5SvOJp7Ar6FzK955TAL0CVR7DOg2duL0TPImw=";
  };

  vendorHash = null;

  nativeBuildInputs = [makeWrapper];

  postInstall = ''
    wrapProgram $out/bin/zhist --prefix PATH : ${lib.makeBinPath [fzf]}
  '';

  meta = {
    description = "Shell history tool for zsh recording working directory, exit status and duration";
    homepage = "https://github.com/overflowy/zhist";
    license = lib.licenses.mit;
    mainProgram = "zhist";
  };
})
