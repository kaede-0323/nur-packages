{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.tmuxinator;
  tmuxinatorOptions = import ./options.nix {inherit lib;};
  yaml = import ./lib-yaml.nix {inherit lib pkgs;};
in {
  options.programs.tmuxinator = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable tmuxinator support in Home-manager";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../../pkgs/tmuxinator {};
      defaultText = lib.literalExpression "nur.repos.kaede-0323.tmuxinator";
      description = "tmuxinator package to install.";
    };

    sessions = lib.mkOption {
      type = lib.types.attrsOf tmuxinatorOptions.sessionType;
      default = {};
      description = "tmuxinator projects written to ~/.tmuxinator, keyed by project name.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = tmuxinatorOptions.removedOptionAssertions "programs.tmuxinator.sessions" cfg.sessions;
    home.packages = lib.mkAfter [cfg.package];
    home.file = lib.mapAttrs' (name: session:
      lib.nameValuePair ".tmuxinator/${name}.yml" {
        source = yaml.generateSessionYaml name session;
      })
    cfg.sessions;
  };
}
