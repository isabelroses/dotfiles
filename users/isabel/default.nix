{ config
, pkgs
, lib
, inputs
, system
, ...
}: let
  system = import ./env.nix;
in {
  imports = [
  ];

  users.users.${system.currentUser} = {
    isNormalUser = true;
    hashedPassword = "$6$pldP2v/cspZEt/2j$QvNZIG.WOPSc1VGPYrK8hgI9zsW1QMr6fVQSZkYVLBXgfcrFkGzedOdmOAYzAMjC6tTKZjYSjQqxmJUm4kSW00";
    extraGroups = [ "networkmanager" "wheel" "docker" "cloudflared" ];
    # packages = with pkgs; [ ];
    shell = pkgs.fish;
  };
  users.groups.cloudflared = { };

  home-manager.users.${system.currentUser} = {
    imports = [
      inputs.hyprland.homeManagerModules.default
      inputs.catppuccin.homeManagerModules.catppuccin
      inputs.sops-nix.homeManagerModules.sops
      ./apps
      ./packages
      ./shells
      ./settings.nix
      #./secrets
    ];
    _module.args = { inherit inputs; };
    home = {
      inherit (config.system) stateVersion;
      username = system.currentUser;
      homeDirectory = "/home/${system.currentUser}";
    };
    manual = {
      html.enable = false;
      json.enable = false;
      manpages.enable = false;
    };
  };
}
