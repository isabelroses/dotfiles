{
  description = "Isabel's dotfiles";

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } { imports = [ ./parts ]; };

  inputs = {
    # our main package supplier
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # lix a good fork of nix
    lix = {
      url = "git+https://git.lix.systems/lix-project/lix.git";
      inputs = {
        nixpkgs.follows = "nixpkgs-small";
        pre-commit-hooks.follows = "";
        nix2container.follows = "";
        flake-compat.follows = "";
      };
    };

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
        flake-utils.follows = "flake-utils";
      };
    };

    # manage userspace with nix
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # we can use this to provide overridable systems
    systems.url = "github:nix-systems/default";

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
        nixpkgs.follows = "nixpkgs-small";
        utils.follows = "flake-utils";
        flake-compat.follows = "";
      };
    };

    # too hard to explain
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs-small";
        nixpkgs-stable.follows = "";
        flake-compat.follows = "";
      };
    };

    # Rust overlay
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs-small";
    };

    ### Security stuff
    # secure-boot on nixos
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        pre-commit-hooks-nix.follows = "";
        flake-utils.follows = "flake-utils";
        flake-compat.follows = "";
      };
    };

    # Secrets, shhh
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs-small";
        darwin.follows = "";
        home-manager.follows = "";
      };
    };

    # firefox user.js
    arkenfox = {
      url = "github:dwarfmaster/arkenfox-nixos";
      inputs = {
        nixpkgs.follows = "nixpkgs-small";
        flake-utils.follows = "flake-utils";
        flake-compat.follows = "";
        pre-commit.follows = "";
      };
    };

    ### Additional packages
    # a plain simple way to host a mail server
    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
      inputs = {
        nixpkgs.follows = "nixpkgs-small";
        nixpkgs-24_05.follows = "";
        flake-compat.follows = "";
      };
    };

    ags = {
      url = "github:Aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs-small";
    };

    # I am not recompling this thanks
    hyprland.url = "git+https://github.com/hyprwm/hyprland?submodules=1";

    # a tree-wide formatter
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs-small";
    };

    ### Fixes
    # remote ssh vscode server
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs = {
        nixpkgs.follows = "nixpkgs-small";
        flake-utils.follows = "flake-utils";
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
      inputs.nixpkgs.follows = "nixpkgs-small";
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
        flake-utils.follows = "flake-utils";
        beapkgs.follows = "beapkgs";
        pre-commit-nix.follows = "pre-commit-hooks";
      };
    };

    # exists for ".follows"
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    # we can remove some eval time with the smaller nixpkgs set
    # do note that it moves faster but has less packages
    nixpkgs-small.url = "github:NixOS/nixpkgs/nixos-unstable-small";
  };
}
