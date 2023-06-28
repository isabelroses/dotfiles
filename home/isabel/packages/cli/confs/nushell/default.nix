{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  programs.nushell = {
    enable = true;
    package = pkgs.nushell;
  };

  home.file = {
    "${config.xdg.configHome}/nushell/config.nu" = lib.mkForce {
      source = config.lib.file.mkOutOfStoreSymlink "/home/isabel/.setup/home/isabel/packages/cli/confs/nushell/config.nu";
    };
    "${config.xdg.configHome}/nushell/env.nu" = lib.mkForce {
      source = config.lib.file.mkOutOfStoreSymlink "/home/isabel/.setup/home/isabel/packages/cli/confs/nushell/env.nu";
    };
    "${config.xdg.configHome}/nushell/history.txt" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.dataHome}/history";
    };
    "${config.xdg.configHome}/nushell/env-nix.nu" = with lib; let
      environmentVariables = {
        EDITOR = "nvim";
        GIT_EDITOR = "nvim";
        VISUAL = "neovide";
        TERMINAL = "alacritty";
      };
    in {
      text = ''
        ${concatStringsSep "\n"
          (mapAttrsToList (k: v: "let-env ${k} = ${v}")
            environmentVariables)}
      '';
    };
    "${config.xdg.configHome}/nushell/scripts" = {
      source = inputs.nu_scripts;
    };
  };
}
