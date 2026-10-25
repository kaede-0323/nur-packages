{
  lib,
  pkgs,
}: let
  yaml = pkgs.formats.yaml {};

  # tmuxinator treats a missing key like null, so unset options are left out.
  withoutNulls = lib.filterAttrs (_: value: value != null);

  # A titled pane is written as a single-key map from title to commands.
  paneConfig = pane:
    if pane.title == null
    then pane.commands
    else {${pane.title} = pane.commands;};

  windowConfig = window: {
    ${window.name} = withoutNulls {
      inherit (window) root layout pre synchronize;
      focused_pane = window.focusedPane;
      panes = map paneConfig window.panes;
    };
  };

  sessionConfig = name: session:
    withoutNulls {
      inherit name;
      inherit (session) root attach;
      socket_name = session.socketName;
      on_project_start = session.onProjectStart;
      on_project_first_start = session.onProjectFirstStart;
      on_project_restart = session.onProjectRestart;
      on_project_exit = session.onProjectExit;
      on_project_stop = session.onProjectStop;
      pre_window = session.preWindow;
      tmux_options = lib.mapNullable (lib.concatStringsSep " ") session.tmuxOptions;
      tmux_command = session.tmuxCommand;
      startup_window = session.startupWindow;
      startup_pane = session.startupPane;
      enable_pane_titles = session.enablePaneTitles;
      pane_title_position = session.paneTitlePosition;
      pane_title_format = session.paneTitleFormat;
      windows = map windowConfig session.windows;
    };
in {
  generateSessionYaml = name: session: yaml.generate "${name}.yml" (sessionConfig name session);
}
