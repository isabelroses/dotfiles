{ inputs, ... }:
{
  imports = [
    inputs.noshell.nixosModules.default
  ];

  # this will set the default shell for all users to noshell you can change
  # this by setting the shell in the user module.
  #
  # each user should set their own shell via
  # `xdg.configFile."shell".source = lib.getExe pkgs.shell;`
  programs.noshell.enable = true;
}
