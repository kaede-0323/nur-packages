{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tmuxinator;
  tmuxinatorOptions = import ./options.nix {inherit lib;};
  yaml = import ./lib-yaml.nix {inherit lib pkgs;};
in {
  options.tmuxinator = {
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../../pkgs/tmuxinator {};
      defaultText = lib.literalExpression "nur.repos.kaede-0323.tmuxinator";
      description = "tmuxinator package to install.";
    };

    sessions = lib.mkOption {
      type = lib.types.attrsOf tmuxinatorOptions.sessionType;
      default = {};
      description = "tmuxinator projects written to /etc/tmuxinator, keyed by project name.";
    };
  };

  config = {
    assertions = tmuxinatorOptions.removedOptionAssertions "tmuxinator.sessions" cfg.sessions;
    environment.systemPackages = lib.mkAfter [cfg.package];
    environment.etc = lib.mapAttrs' (name: session:
      lib.nameValuePair "tmuxinator/${name}.yml" {
        source = yaml.generateSessionYaml name session;
      })
    cfg.sessions;
    # tmuxinator does not search /etc, so point it there explicitly.
    environment.variables.TMUXINATOR_CONFIG = lib.mkIf (cfg.sessions != {}) "/etc/tmuxinator";
  };
}
