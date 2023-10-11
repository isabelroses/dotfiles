{pkgs, ...}: {
  imports = [
    ./micro
    #./nvim
    ./nvim-flake
    ./vscode
  ];
  config.home.packages = with pkgs; [arduino];
}
