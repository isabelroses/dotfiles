{
  lib,
  osClass,
  ...
}:
let
  inherit (lib) mkOption mapAttrs;
  inherit (lib.types) enum nullOr str;

  mkDefault = name: args: mkOption ({ description = "default ${name} for the system"; } // args);
in
{
  options.garden.programs.defaults = mapAttrs mkDefault {
    shell = {
      type = enum [
        "bash"
        "zsh"
        "fish"
        "nushell"
      ];
      default = if (osClass == "nixos") then "bash" else "zsh";
    };

    terminal = {
      type = enum [
        "ghostty"
        "wezterm"
      ];
      default = "ghostty";
    };

    editor = {
      type = enum [
        "nvim"
        "codium"
      ];
      default = "nvim";
    };

    pager = {
      type = str;
      default = "less -FR";
    };

    manpager = {
      type = str;
      default = "nvim +Man!";
    };

    screenLocker = {
      type = nullOr (enum [
        "swaylock"
        "gtklock"
      ]);
      default = "gtklock";
      description = ''
        The lockscreen module to be loaded by home-manager.
      '';
    };
  };
}
