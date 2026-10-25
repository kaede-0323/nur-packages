{lib}: let
  inherit (lib) mkOption types;

  nullOption = type: description:
    mkOption {
      type = types.nullOr type;
      default = null;
      inherit description;
    };

  commands = types.either types.str (types.listOf types.str);

  # Options this module used to offer that tmuxinator 3.4 does not read, with migration hints.
  removed = {
    session = {
      pre = "Use onProjectStart, or onProjectFirstStart and onProjectRestart.";
      post = "Use onProjectStop or onProjectExit.";
      env = "tmuxinator has no env option; export the variables in preWindow.";
    };
    window = {
      focus = "Use startupWindow on the session, or focusedPane to pick a pane.";
      shell = "tmuxinator has no per-window shell; start the shell from a pane's commands.";
      post = "tmuxinator has no per-window post; append the commands to each pane's commands.";
    };
    pane = {
      command = "Use commands.";
      shell = "tmuxinator has no per-pane shell; start the shell from commands.";
    };
  };

  removedOptions = lib.mapAttrs (_: _:
    mkOption {
      type = types.anything;
      default = null;
      visible = false;
    });

  paneType = types.submodule {
    options =
      removedOptions removed.pane
      // {
        title = nullOption types.str "Pane title, shown when enablePaneTitles is set and usable in focusedPane.";
        commands = mkOption {
          type = types.listOf types.str;
          default = [];
          description = "Commands sent to the pane.";
        };
      };
  };

  windowType = types.submodule {
    options =
      removedOptions removed.window
      // {
        name = mkOption {
          type = types.str;
          description = "Window name.";
        };
        root = nullOption types.str "Window root, resolved against the session root when relative.";
        layout = nullOption types.str "tmux layout applied to the window.";
        pre = nullOption commands "Commands run in each pane before its own commands.";
        focusedPane = nullOption (types.either types.int types.str) "Pane selected in this window, by index or title.";
        synchronize = nullOption (types.either types.bool (types.enum ["before" "after"])) "Whether to synchronize panes, before or after their commands run.";
        panes = mkOption {
          type = types.listOf paneType;
          default = [];
          description = "Panes in the window.";
        };
      };
  };

  sessionType = types.submodule {
    options =
      removedOptions removed.session
      // {
        root = nullOption types.str "Project root directory.";
        socketName = nullOption types.str "tmux socket name.";
        onProjectStart = nullOption commands "Commands run on every project start.";
        onProjectFirstStart = nullOption commands "Commands run when the session does not exist yet.";
        onProjectRestart = nullOption commands "Commands run when the session already exists.";
        onProjectExit = nullOption commands "Commands run when detaching from the session.";
        onProjectStop = nullOption commands "Commands run by tmuxinator stop.";
        preWindow = nullOption commands "Commands run in every window and pane before their own commands.";
        tmuxOptions = nullOption (types.listOf types.str) "Command line options passed to tmux.";
        tmuxCommand = nullOption types.str "Command run instead of tmux, such as byobu.";
        startupWindow = nullOption (types.either types.int types.str) "Window selected on startup, by index or name.";
        startupPane = nullOption types.int "Pane of the startup window selected on startup, by index.";
        attach = nullOption types.bool "Whether to attach to the session after starting it.";
        enablePaneTitles = nullOption types.bool "Whether to show pane titles.";
        paneTitlePosition = nullOption (types.enum ["top" "bottom" "off"]) "Where pane titles are shown.";
        paneTitleFormat = nullOption types.str "tmux format string for pane titles.";
        windows = mkOption {
          type = types.listOf windowType;
          default = [];
          description = "Windows in the session.";
        };
      };
  };

  removedOptionAssertions = prefix: sessions: let
    check = path: table: attrs:
      lib.mapAttrsToList (option: hint: {
        assertion = attrs.${option} == null;
        message = "${path}.${option} has been removed. ${hint}";
      })
      table;

    checkWindow = path: window:
      check path removed.window window
      ++ lib.concatLists (lib.imap0 (i: check "${path}.panes.${toString i}" removed.pane) window.panes);

    checkSession = name: session:
      check "${prefix}.${name}" removed.session session
      ++ lib.concatLists (lib.imap0 (i: checkWindow "${prefix}.${name}.windows.${toString i}") session.windows);
  in
    lib.concatLists (lib.mapAttrsToList checkSession sessions);
in {
  inherit sessionType removedOptionAssertions;
}
