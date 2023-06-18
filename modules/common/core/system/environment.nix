{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  doas = pkgs.writeScriptBin "sudo" ''exec doas "$@"'';
in {
  environment = {
    # variables that I want to set globally on all systems
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      SYSTEMD_PAGERSECURE = "true";
      PAGER = "less -FR";
      FLAKE = "/home/isabel/.setup";
    };

    # packages I want pre-installed on all systems
    systemPackages = with pkgs;
      [
        git
        curl
        wget
        pciutils
        lshw
      ]
      ++ optionals (config.security.doas.enable) [
        # add the doas package only if I have doas enabled, instead of sudo
        doas
      ];

    # disable all packages installed by default, so that my system doesn't have anything
    # that I myself have added
    defaultPackages = [];
  };
}
