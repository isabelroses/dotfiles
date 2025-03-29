{ lib, config, ... }:
let
  inherit (lib.modules) mkIf;
in
{
  config = mkIf (config.garden.environment.desktop == "aerospace") {
    programs.aerospace = {
      enable = true;

      userSettings = {
        enable-normalization-flatten-containers = true;
        enable-normalization-opposite-orientation-for-nested-containers = true;

        gaps = {
          inner = {
            horizontal = 5;
            vertical = 5;
          };

          outer = {
            left = 5;
            bottom = 5;
            top = 5;
            right = 5;
          };
        };

        # quote the if as its a language feature
        on-window-detected = [
          {
            "if".app-id = "com.mitchellh.ghostty";
            run = "move-node-to-workspace 1";
          }
          {
            "if".app-id = "com.github.wez.wezterm";
            run = "move-node-to-workspace 1";
          }
          {
            "if".app-id = "company.thebrowser.Browser";
            run = "move-node-to-workspace 2";
          }
          {
            "if".app-id = "com.hnc.Discord";
            run = "move-node-to-workspace 3";
          }
        ];

        mode = {
          main.binding = {
            alt-d = "exec-and-forget raycast";
            alt-enter = "exec-and-forget ghostty";
            alt-b = "exec-and-forget arc";

            alt-shift-j = "move left";
            alt-shift-k = "move down";
            alt-shift-l = "move up";
            alt-shift-semicolon = "move right";

            alt-shift-space = "layout floating tiling";

            alt-1 = "workspace 1";
            alt-2 = "workspace 2";
            alt-3 = "workspace 3";
            alt-4 = "workspace 4";
            alt-5 = "workspace 5";
            alt-6 = "workspace 6";
            # alt-7 = "workspace 7";
            # alt-8 = "workspace 8";
            # alt-9 = "workspace 9";
            # alt-0 = "workspace 10";

            alt-shift-1 = "move-node-to-workspace 1";
            alt-shift-2 = "move-node-to-workspace 2";
            alt-shift-3 = "move-node-to-workspace 3";
            alt-shift-4 = "move-node-to-workspace 4";
            alt-shift-5 = "move-node-to-workspace 5";
            alt-shift-6 = "move-node-to-workspace 6";
            # alt-shift-7 = "move-node-to-workspace 7";
            # alt-shift-8 = "move-node-to-workspace 8";
            # alt-shift-9 = "move-node-to-workspace 9";
            # alt-shift-0 = "move-node-to-workspace 10";

            alt-r = "mode resize";
          };

          resize.binding = {
            h = "resize width -50";
            j = "resize height +50";
            k = "resize height -50";
            l = "resize width +50";
            enter = "mode main";
            esc = "mode main";
          };
        };
      };
    };
  };
}
