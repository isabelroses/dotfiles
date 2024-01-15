{
  description = "Isabel's dotfiles";

  outputs = {
    self,
    nixpkgs,
    flake-parts,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} ({withSystem, ...}: {
      # The system archtecitures, more can be added as needed
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      imports = [
        {config._module.args._inputs = inputs // {inherit (inputs) self;};}

        inputs.flake-parts.flakeModules.easyOverlay

        # flake parts
        ./flake/makeSys.nix # args that is passsed to the flake, moved away from the main file

        # flake part programs
        ./flake/programs/pre-commit.nix # pre-commit hooks
        ./flake/programs/treefmt.nix # treefmt configuration

        ./flake/pkgs # packages exposed to the flake
        ./flake/overlays # overlays that make the system that bit cleaner
        ./flake/templates # programing templates for the quick setup of new programing enviorments
        ./flake/schemas # nix schemas. whenever they actually work
        ./flake/modules # nixos and home-manager modules
      ];

      flake = let
        # extended nixpkgs lib, with additonal features
        lib = import ./lib {inherit inputs;};
      in {
        nixosConfigurations = import ./hosts {inherit nixpkgs self lib withSystem;};

        # build with `nix build .#images.<hostname>`
        # alternatively hosts can be built with `nix build .#nixosConfigurations.hostName.config.system.build.isoImage`
        images = import ./hosts/images.nix {inherit inputs self lib;};
      };

      perSystem = {
        config,
        # inputs',
        pkgs,
        ...
      }: {
        imports = [{_module.args.pkgs = config.legacyPackages;}];

        # formatter for nix fmt
        formatter = pkgs.alejandra;

        # checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) inputs.deploy-rs.lib;

        devShells.default = pkgs.mkShell {
          name = "dotfiles";
          meta.description = "Devlopment shell for this configuration";

          shellHook = ''
            ${config.pre-commit.installationScript}
          '';

          # tell direnv to shut up
          DIRENV_LOG_FORMAT = "";

          packages = with pkgs; [
            # inputs'.deploy-rs.packages.deploy-rs # remote deployment
            git # flakes require git
            nil # nix language server
            statix # lints and suggestions
            deadnix # clean up unused nix code
            alejandra # nix formatter
            nodejs # ags
            config.treefmt.build.wrapper # treewide formatter
          ];

          inputsFrom = [config.treefmt.build.devShell];
        };
      };
    });

  inputs = {
    # choose our nixpkgs version
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Packages for Wayland
    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # project shells
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # too hard to explain
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs";
      };
    };

    nix-index-db = {
      url = "github:nix-community/nix-index-database";
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

    # mailserver on nixos
    simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/master";

    # remote ssh vscode server
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # deploy remote systems
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        utils.follows = "pre-commit-hooks/flake-utils";
        flake-compat.follows = "pre-commit-hooks/flake-compat";
      };
    };

    # secure-boot on nixos
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        pre-commit-hooks-nix.follows = "pre-commit-hooks";
        flake-utils.follows = "pre-commit-hooks/flake-utils";
        flake-compat.follows = "pre-commit-hooks/flake-compat";
      };
    };

    # Secrets, shhh
    sops = {
      url = "github:Mic92/sops-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs";
      };
    };

    # Hyprland packages
    hyprland.url = "github:hyprwm/Hyprland";
    hyprpicker.url = "github:hyprwm/hyprpicker";
    xdg-portal-hyprland = {
      url = "github:hyprwm/xdg-desktop-portal-hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim = {
      url = "github:isabelroses/nvim";
      # url = "git+file:///home/isabel/dev/nvim";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nil.follows = "nil";
        flake-parts.follows = "flake-parts";
        pre-commit-nix.follows = "pre-commit-hooks";
        flake-utils.follows = "pre-commit-hooks/flake-utils";
      };
    };

    # my website
    isabelroses-website = {
      url = "github:isabelroses/website";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # a tree-wide formatter
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # More up to date auto-cpufreq
    auto-cpufreq = {
      url = "github:AdnanHodzic/auto-cpufreq";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # cool bars
    ags = {
      url = "github:Aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix helper
    nh = {
      url = "github:viperML/nh";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Run unpatched dynamic binaries on NixOS
    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # lovely app
    bellado.url = "github:isabelroses/bellado";

    # Firefox but really locked down and air tight
    schizofox = {
      url = "github:schizofox/schizofox";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };

    # More up to date minecraft launcher
    prism-launcher = {
      url = "github:PrismLauncher/PrismLauncher";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        pre-commit-hooks.follows = "pre-commit-hooks";
        flake-compat.follows = "pre-commit-hooks/flake-compat";
      };
    };

    # catppuccin related items
    catppuccinifier = {
      url = "github:lighttigerXIV/catppuccinifier";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "pre-commit-hooks/flake-utils";
      };
    };
    catppuccin.url = "github:Stonks3141/ctp-nix";
    catppuccin-vsc = {
      url = "github:catppuccin/vscode";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin-toolbox = {
      url = "github:catppuccin/toolbox";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # icat wrapper
    icat-wrapper = {
      url = "github:nekowinston/icat";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Schemas
    flake-schemas.url = "github:DeterminateSystems/flake-schemas";
    nixSchemas.url = "github:DeterminateSystems/nix/flake-schemas";
  };

  # This allows for the gathering of prebuilt binaries, making building much faster
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://nix-gaming.cachix.org"
      "https://isabelroses.cachix.org"
      "https://pre-commit-hooks.cachix.org"
      "https://cache.garnix.io"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      "isabelroses.cachix.org-1:mXdV/CMcPDaiTmkQ7/4+MzChpOe6Cb97njKmBQQmLPM="
      "pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBo7Rc="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };
}
