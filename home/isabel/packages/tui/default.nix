{
  pkgs,
  osConfig,
  lib,
  ...
}:
{
  config = lib.mkIf osConfig.garden.programs.tui.enable {
    home.packages = with pkgs; [
      # wishlist # fancy ssh
      glow # fancy markdown
      fx # fancy jq
      gum # a nicer scripting
      nix-tree # view nix derivations in a tui
    ];
  };
}
