{ pkgs, ... }:
{
  programs.quickshell = {
    package = pkgs.symlinkJoin {
      name = "quickshell-wrapped";
      paths = [
        pkgs.quickshell
        pkgs.kdePackages.qtimageformats
        pkgs.adwaita-icon-theme
        pkgs.kdePackages.kirigami.unwrapped
      ];
      meta.mainProgram = pkgs.quickshell.meta.mainProgram;
    };

    systemd.enable = true;
  };
}
