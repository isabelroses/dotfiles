{ pkgs, ... }:
{
  programs.quickshell = {
    package = pkgs.symlinkJoin {
      name = "quickshell-wrapped";
      paths = [
        pkgs.quickshell
        pkgs.kdePackages.qtimageformats
      ];
      meta.mainProgram = pkgs.quickshell.meta.mainProgram;
    };

    systemd.enable = true;
  };
}
