{
  description = "Flameing hot trash";

  outputs = {
    self,
    nixpkgs,
    flake-parts,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
      ];

      imports = [
        {config._module.args._inputs = inputs // {inherit (inputs) self;};}
      ];

      flake = let
        # extended nixpkgs lib, contains my custom functions
        lib = import ./lib {inherit nixpkgs lib inputs;};
      in {
        # entry-point for nixos configurations
        nixosConfigurations = import ./hosts {inherit nixpkgs self lib;};
      };

      perSystem = {
        config,
        inputs',
        pkgs,
        system,
        ...
      }: {
        imports = [
          {
            _module.args.pkgs = import nixpkgs {
              config.allowUnfree = true;
              config.allowUnsupportedSystem = true;
              inherit system;
            };
          }
        ];

        devShells.default = inputs'.devshell.legacyPackages.mkShell {
          name = "nyx";
          commands = (import ./lib/flake/devShell).shellCommands;
          packages = with pkgs; [
            nil # nix ls
            alejandra # formatter
            git # flakes require git, and so do I
            glow # markdown viewer
            statix # lints and suggestions
            deadnix # clean up unused nix code
          ];
        };

        # provide the formatter for nix fmt
        formatter = pkgs.alejandra;

        # packages
        packages = {
          # A copy of Hyprland with its nixpkgs overriden
          # cannot trigger binary cache pulls, so I push it to my own
          hyprland-cached = inputs'.hyprland.packages.default;
        };
      };
    };

  inputs = {
    # Nix helper
    nh = {
      url = "github:viperML/nh";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "nixpkgs/nixos-23.05";

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Automated, pre-built packages for Wayland
    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix gaming packages
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Rust overlay
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix Language server
    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };

    catppuccin.url = "github:isabelroses/ctp-nix";

    # Hyprland packages
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprpicker = {
      url = "github:hyprwm/hyprpicker";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    xdg-portal-hyprland = {
      url = "github:hyprwm/xdg-desktop-portal-hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # secure-boot on nixos
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://nix-gaming.cachix.org"
      "https://hyprland.cachix.org"
      "https://isabelroses.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "isabelroses.cachix.org-1:mXdV/CMcPDaiTmkQ7/4+MzChpOe6Cb97njKmBQQmLPM="
    ];
  };
}
