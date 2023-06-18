{
  pkgs,
  inputs,
  ...
}: {
  home = {
    packages = with pkgs; [
      alejandra
      deadnix
      nix-index
      statix
    ];

    sessionVariables = {
      DIRENV_LOG_FORMAT = "";
    };
  };

  programs.direnv = {
    enableZshIntegration = true;

    enable = true;
    nix-direnv = {
      enable = true;
    };
  };
}
