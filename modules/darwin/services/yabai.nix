{ lib, config, ... }:
let
  inherit (lib.modules) mkIf;
  inherit (lib.strings) concatLines;
in
{
  config = mkIf (config.garden.environment.desktop == "yabai") {
    # https://github.com/koekeishiya/yabai#requirements-and-caveats
    system.defaults = {
      # whether to automatically rearrange spaces based on most recent use
      dock.mru-spaces = false;

      # Apple menu > System Preferences > Mission Control > Displays have separate Space
      spaces.spans-displays = false;
    };

    services.yabai = {
      enable = true;
      enableScriptingAddition = true;

      # logFile = "/var/tmp/yabai.log";

      config = {
        auto_balance = "off";
        focus_follows_mouse = "off";
        layout = "bsp";
        mouse_drop_action = "swap";
        mouse_follows_focus = "off";
        window_animation_duration = "0.0";
        window_gap = 5;
        left_padding = 5;
        right_padding = 5;
        top_padding = 5;
        bottom_padding = 5;
        window_origin_display = "default";
        window_placement = "second_child";
        window_shadow = "float";
      };

      extraConfig =
        let
          rule = "yabai -m rule --add";
          ignored = app: concatLines (map (e: ''${rule} app="${e}" manage=off sticky=off layer=above'') app);
          unmanaged = app: concatLines (map (e: ''${rule} app="${e}" manage=off'') app);
        in
        ''
          # auto-inject scripting additions
          yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"
          sudo yabai --load-sa

          ${ignored [
            "JetBrains Toolbox"
            "Sip"
            "iStat Menus"
          ]}
          ${unmanaged [ "Steam" ]}
          yabai -m rule --add label="Finder" app="^Finder$" title="(Co(py|nnect)|Move|Info|Pref)" manage=off
          yabai -m rule --add label="Safari" app="^Safari$" title="^(General|(Tab|Password|Website|Extension)s|AutoFill|Se(arch|curity)|Privacy|Advance)$" manage=off
          yabai -m rule --add label="Arc" app="^Arc$" title="^(General|(Tab|Password|Website|Extension)s|AutoFill|Se(arch|curity)|Privacy|Advance|[Bb]itwarden)$" manage=off

          # etc.
          ${rule} manage=off app="CleanShot"
          ${rule} manage=off sticky=on  app="OBS Studio"
        '';
    };
  };
}
