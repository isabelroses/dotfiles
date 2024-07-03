{ lib, config, ... }:
let
  inherit (lib) mkIf;
in
{
  services.skhd = mkIf (config.garden.environment.desktop == "yabai") {
    enable = true;
    skhdConfig =
      let
        mapKeymaps =
          with builtins;
          cmd:
          concatStringsSep "\n" (
            map (i: replaceStrings [ "Num" ] [ (toString (if (i == 10) then 0 else i)) ] cmd) (lib.range 1 10)
          );
      in
      ''
        #!/usr/bin/env sh

        # focus window
        cmd + ctrl - h : yabai -m window --focus west
        cmd + ctrl - j : yabai -m window --focus south
        cmd + ctrl - k : yabai -m window --focus north
        cmd + ctrl - l : yabai -m window --focus east

        # move window
        cmd + shift - h : yabai -m window --warp west
        cmd + shift - j : yabai -m window --warp south
        cmd + shift - k : yabai -m window --warp north
        cmd + shift - l : yabai -m window --warp east

        # toggle sticky/floating
        cmd + shift - s: yabai -m window --toggle sticky --toggle float --toggle topmost
        cmd + shift - d: yabai -m window --toggle float

        # fullacreen
        shift + alt - f : yabai -m window --toggle native-fullscreen

        # open apps
        cmd - return : open -na "$HOME/Applications/Home Manager Apps/WezTerm.app"
        cmd - b : open -na "Arc"
        cmd - e : open -na "Finder"

        # ONLY WORKS WITH SIP DISABLED:
        # switch to space
        ${mapKeymaps "cmd + ctrl - Num : yabai -m space --focus Num"}
        # send window to desktop and follow focus
        ${mapKeymaps "cmd + shift - Num : yabai -m window --space Num; yabai -m space --focus Num"}
      '';
  };
}
