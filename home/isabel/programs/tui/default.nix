{
  pkgs,
  osConfig,
  lib,
  ...
}: {
  imports = [
    ./confs
  ];

  config = lib.mkIf osConfig.modules.programs.tui.enable {
    home.packages = with pkgs; [
      wishlist # fancy ssh
      glow # fancy markdown
      fx # fancy jq
    ];
  };
}
