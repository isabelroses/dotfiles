{
  description = "Isabel's dotfiles";

  outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} {imports = [./parts];};

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
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "";
        flake-utils.follows = "izvim/flake-utils";
      };
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

    # too hard to explain
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
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

    # mailserver on nixos
    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/master";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        utils.follows = "izvim/flake-utils";
      };
    };

    # remote ssh vscode server
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "izvim/flake-utils";
      };
    };

    # deploy remote systems
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        utils.follows = "izvim/flake-utils";
        flake-compat.follows = "izvim/flake-compat";
      };
    };

    # secure-boot on nixos
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        pre-commit-hooks-nix.follows = "";
        flake-utils.follows = "izvim/flake-utils";
        flake-compat.follows = "izvim/flake-compat";
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

    nekowinston-nur = {
      url = "github:nekowinston/nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    izvim = {
      url = "github:isabelroses/nvim";
      inputs = {
        nixpkgs.follows = "nixpkgs";
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
    bellado = {
      url = "github:isabelroses/bellado";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    izrss = {
      url = "github:isabelroses/izrss";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zzz = {
      url = "github:isabelroses/zzz";
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

    # Run unpatched dynamic binaries on NixOS
    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Firefox but really locked down and air tight
    schizofox = {
      url = "github:schizofox/schizofox";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };

    # A cool terminal
    # WARNING: do not change the overrides since we will have to rebuild from source and that will take forever
    ghostty.url = "git+ssh://git@github.com/mitchellh/ghostty";

    # Hyprland packages
    hyprland.url = "github:hyprwm/Hyprland";
    hyprpicker.url = "github:hyprwm/hyprpicker";
    xdg-portal-hyprland.url = "github:hyprwm/xdg-desktop-portal-hyprland";

    # catppuccin related items
    catppuccin.url = "github:catppuccin/nix";
    catppuccinifier = {
      url = "github:lighttigerXIV/catppuccinifier";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "izvim/flake-utils";
      };
    };
    catppuccin-vsc = {
      url = "github:catppuccin/vscode";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
