{
  description = "Flameing hot trash";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    hyprland.url = "github:hyprwm/Hyprland";
    catppuccin-toolbox.url = "github:catppuccin/toolbox";
    catppuccin.url = "github:Stonks3141/ctp-nix";
    sops-nix.url = "github:Mic92/sops-nix";
    home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    xdg-desktop-portal-hyprland = {
      url = "github:hyprwm/xdg-desktop-portal-hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, home-manager, nixpkgs, nixpkgs-unstable, catppuccin, sops-nix, hyprland, ... } @ inputs:
  let
    system = import ./users/isabel/env.nix;
    overlays = final: prev: {
      unstable = import nixpkgs-unstable {
        system = prev.system;
        config.allowUnfree = true;
      };
    };
    pkgs = import nixpkgs {
      config = {
        allowBroken = true;
        allowUnfree = true;
        tarball-ttl = 0;
      };
    };
  in
    {
      nixosConfigurations.hydra = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/hydra
          home-manager.nixosModules.home-manager
          {
            home-manager = { 
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {
                flakePath = "/home/${system.currentUser}/.setup";
                inherit system inputs;
              };
            };
          }
          sops-nix.nixosModules.sops
          catppuccin.nixosModules.catppuccin
          hyprland.nixosModules.default
          {programs.hyprland.enable = true;}
          # ({config, ...}: {
          #     config = {
          #       nixpkgs.overlays = [overlays];
          #     };
          #   })
        ];
        specialArgs = { inherit system inputs; };
      };
    };
}
