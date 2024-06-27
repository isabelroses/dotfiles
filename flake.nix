{
  description = "Isabel's dotfiles";

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } { imports = [ ./parts ]; };

  inputs = {
    # our main package supplier
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # lix a good fork of nix
    lix.url = "git+https://git.lix.systems/lix-project/lix.git";

    # improved support for darwin
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # improved support for wsl
    nixos-wsl = {
      # url = "github:nix-community/NixOS-WSL";
      url = "github:getchoo/NixOS-WSL/hardware-graphics";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "";
        flake-utils.follows = "izvim/flake-utils";
      };
    };

    # manage userspace with nix
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # bring all the mess together with flake-parts
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    ### Flake management
    # deploy systems remotely
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        utils.follows = "izvim/flake-utils";
        flake-compat.follows = "";
      };
    };

    # too hard to explain
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs";
      };
    };

    # Rust overlay
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ### Security stuff
    # secure-boot on nixos
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        pre-commit-hooks-nix.follows = "";
        flake-utils.follows = "izvim/flake-utils";
        flake-compat.follows = "";
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

    # firefox user.js
    arkenfox = {
      url = "github:dwarfmaster/arkenfox-nixos";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "";
        pre-commit.follows = "";
        flake-utils.follows = "lanzaboote/flake-utils";
      };
    };

    ### Additional packages
    # a plain simple way to host a mail server
    simple-nixos-mailserver = {
      url = "gitlab:isabelroses/nixos-mailserver/master";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-24_05.follows = "";
        flake-compat.follows = "";
      };
    };

    ags = {
      url = "github:Aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # I am not recompling this thanks
    hyprland.url = "git+https://github.com/hyprwm/hyprland?submodules=1";

    # a tree-wide formatter
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ### Fixes
    # remote ssh vscode server
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "izvim/flake-utils";
      };
    };

    # Run unpatched dynamic binaries on NixOS
    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ### misc
    # a index for nixpkgs
    nix-index-db = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # declarative theme management
    catppuccin.url = "github:catppuccin/nix";

    ### my programs
    beapkgs = {
      url = "github:isabelroses/beapkgs/60401cc3987ea906fc78c593909926cbec5e6393";
      # url = "git+file:///home/isabel/dev/beapkgs";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "";
      };
    };

    izvim = {
      url = "github:isabelroses/nvim";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        beapkgs.follows = "beapkgs";
        pre-commit-nix.follows = "pre-commit-hooks";
      };
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
