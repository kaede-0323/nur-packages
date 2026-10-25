{
  lib,
  buildRubyGem,
  ruby,
  installShellFiles,
}: let
  gem = gemName: version: sha256:
    buildRubyGem {
      inherit ruby gemName version;
      name = "ruby${ruby.version}-${gemName}-${version}";
      source.sha256 = sha256;
    };
in
  # bundlerEnv sets BUNDLE_FROZEN, which breaks Bundler-based commands run inside tmuxinator.
  buildRubyGem rec {
    inherit ruby;
    name = "${gemName}-${version}";
    gemName = "tmuxinator";
    version = "3.4.2";
    source.sha256 = "sha256-MPkHdXFC2Moqfy0ZzlmiTRRlE7JjRrYOLBv6IAPU7kw=";

    propagatedBuildInputs = [
      (gem "erubi" "1.13.0" "fca61b47daefd865d0fb50d168634f27ad40181867445badf6427c459c33cd62")
      (gem "thor" "1.4.0" "sha256-h2PoIsyw8de+6IzeExsZplYGZXuEfMe3tLgudyvNij0=")
      (gem "xdg" "2.2.5" "04xr4cavnzxlk926pkji7b5yiqy4qsd3gdvv8mg6jliq6sczg9gk")
    ];

    nativeBuildInputs = [installShellFiles];

    postInstall = ''
      installShellCompletion $GEM_HOME/gems/${gemName}-${version}/completion/tmuxinator.{bash,zsh,fish}
    '';

    meta = {
      description = "Manage complex tmux sessions easily";
      homepage = "https://github.com/tmuxinator/tmuxinator";
      license = lib.licenses.mit;
      mainProgram = "tmuxinator";
      platforms = lib.platforms.unix;
    };
  }
