{
  description = "Isabel's dotfiles";

  outputs = {
    self,
    flake-parts,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} ({withSystem, ...}: {
      # The system archtecitures, more can be added as needed
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      imports = [
        # add self back to inputs to use as `inputs.self`
        # I depend on inputs.self *at least* once
        {config._module.args._inputs = inputs // {inherit (inputs) self;};}

        inputs.flake-parts.flakeModules.easyOverlay

        ./parts # flake parts
      ];

      flake = let
        lib = import ./lib {inherit inputs;};
      in
        import ./hosts {inherit lib withSystem;};
    });

  inputs = {
    # choose our nixpkgs version
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # darwin systems are important
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixos on wsl
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
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

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
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
    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/master";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        utils.follows = "neovim/flake-utils";
      };
    };

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
        utils.follows = "neovim/flake-utils";
        flake-compat.follows = "neovim/flake-compat";
      };
    };

    # secure-boot on nixos
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        pre-commit-hooks-nix.follows = "pre-commit-hooks";
        flake-utils.follows = "neovim/flake-utils";
        flake-compat.follows = "neovim/flake-compat";
      };
    };

    # Secrets, shhh
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    # Hyprland packages
    hyprland.url = "github:hyprwm/Hyprland";
    hyprpicker.url = "github:hyprwm/hyprpicker";
    xdg-portal-hyprland = {
      url = "github:hyprwm/xdg-desktop-portal-hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nekowinston-nur = {
      url = "github:nekowinston/nur";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "neovim/flake-utils";
      };
    };

    neovim = {
      url = "github:isabelroses/nvim";
      # url = "git+file:///home/isabel/dev/nvim";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nil.follows = "nil";
        flake-parts.follows = "flake-parts";
        nekowinston-nur.follows = "nekowinston-nur";
        pre-commit-nix.follows = "pre-commit-hooks";
      };
    };

    # my website
    isabelroses-website = {
      url = "github:isabelroses/website";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    blahaj = {
      url = "github:isabelroses/blahaj";
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

    # catppuccin related items
    catppuccinifier = {
      url = "github:lighttigerXIV/catppuccinifier";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "neovim/flake-utils";
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
