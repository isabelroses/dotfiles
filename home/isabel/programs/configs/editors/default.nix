{pkgs, ...}: {
  imports = [
    ./micro
    ./nvim
    ./vscode
  ];

  # need this one for uni
  config.home.packages = with pkgs; [
    jetbrains.idea-ultimate
    # arduino
    # arduino-cli
  ];
}
