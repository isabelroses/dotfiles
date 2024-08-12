{
  description = "Isabel's dotfiles";

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } { imports = [ ./parts ]; };

  inputs = {
    # our main package supplier
    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "bdcd19eff5d2b9f596934bfd900cc8fdcd54489c";
    };

    # lix a good fork of nix
    lix = {
      type = "git";
      url = "https://git.lix.systems/lix-project/lix.git";

      inputs = {
        nixpkgs.follows = "nixpkgs-small";
        pre-commit-hooks.follows = "";
        nix2container.follows = "";
        flake-compat.follows = "";
      };
    };

    # improved support for darwin
    darwin = {
      type = "github";
      owner = "lnl7";
      repo = "nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # improved support for wsl
    nixos-wsl = {
      type = "github";
      owner = "nix-community";
      repo = "NixOS-WSL";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "";
        flake-utils.follows = "flake-utils";
      };
    };

    # manage userspace with nix
    home-manager = {
      type = "github";
      owner = "nix-community";
      repo = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # we can use this to provide overridable systems
    systems = {
      type = "github";
      owner = "nix-systems";
      repo = "default";
    };

    # bring all the mess together with flake-parts
    flake-parts = {
      type = "github";
      owner = "hercules-ci";
      repo = "flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    ### Flake management
    # deploy systems remotely
    deploy-rs = {
      type = "github";
      owner = "serokell";
      repo = "deploy-rs";

      inputs = {
        nixpkgs.follows = "nixpkgs-small";
        utils.follows = "flake-utils";
        flake-compat.follows = "";
      };
    };

    # this adds pre commit hooks via nix to our repo
    git-hooks = {
      type = "github";
      owner = "cachix";
      repo = "git-hooks.nix";

      inputs = {
        nixpkgs.follows = "nixpkgs-small";
        nixpkgs-stable.follows = "";
        flake-compat.follows = "";
      };
    };

    ### Security stuff
    # secure-boot on nixos
    lanzaboote = {
      type = "github";
      owner = "nix-community";
      repo = "lanzaboote";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        rust-overlay.follows = "beapkgs/rust-overlay";
        pre-commit-hooks-nix.follows = "";
        flake-compat.follows = "";
      };
    };

    # Secrets, shhh
    agenix = {
      type = "github";
      owner = "ryantm";
      repo = "agenix";

      inputs = {
        nixpkgs.follows = "nixpkgs-small";
        darwin.follows = "";
        home-manager.follows = "";
        systems.follows = "systems";
      };
    };

    # firefox user.js
    arkenfox = {
      type = "github";
      owner = "dwarfmaster";
      repo = "arkenfox-nixos";

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
      type = "gitlab";
      owner = "simple-nixos-mailserver";
      repo = "nixos-mailserver";

      inputs = {
        nixpkgs.follows = "nixpkgs-small";
        nixpkgs-24_05.follows = "";
        flake-compat.follows = "";
      };
    };

    ags = {
      type = "github";
      owner = "isabelroses";
      repo = "ags";

      inputs = {
        nixpkgs.follows = "nixpkgs-small";
        systems.follows = "systems";
      };
    };

    comfywm = {
      url = "git+ssh://git@git.isabelroses.com:2222/isabel/comfywm";
      # url = "path:/home/isabel/dev/comfywm";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        rust-overlay.follows = "beapkgs/rust-overlay";
      };
    };

    # I am not recompling this thanks
    hyprland = {
      type = "git";
      url = "https://github.com/hyprwm/Hyprland";
      submodules = true;

      inputs.systems.follows = "systems";
    };

    # a tree-wide formatter
    treefmt-nix = {
      type = "github";
      owner = "numtide";
      repo = "treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs-small";
    };

    ### Fixes
    # remote ssh vscode server
    vscode-server = {
      type = "github";
      owner = "nix-community";
      repo = "nixos-vscode-server";

      inputs = {
        nixpkgs.follows = "nixpkgs-small";
        flake-utils.follows = "flake-utils";
      };
    };

    ### misc
    # a index for nixpkgs
    nix-index-db = {
      type = "github";
      owner = "nix-community";
      repo = "nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs-small";
    };

    # declarative theme management
    catppuccin = {
      type = "github";
      owner = "catppuccin";
      repo = "nix";
    };

    ### my programs
    beapkgs = {
      type = "github";
      owner = "isabelroses";
      repo = "beapkgs";
      # url = "path:/home/isabel/dev/beapkgs";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "";
      };
    };

    izvim = {
      type = "github";
      owner = "isabelroses";
      repo = "nvim";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
        flake-parts.follows = "flake-parts";
        beapkgs.follows = "beapkgs";
        git-hooks.follows = "";
      };
    };

    # exists for ".follows"
    flake-utils = {
      type = "github";
      owner = "numtide";
      repo = "flake-utils";
      inputs.systems.follows = "systems";
    };

    # we can remove some eval time with the smaller nixpkgs set
    # do note that it moves faster but has less packages
    nixpkgs-small = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-unstable-small";
    };
  };
}
