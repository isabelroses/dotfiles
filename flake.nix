{
  description = "Isabel's dotfiles";

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } { imports = [ ./parts ]; };

  inputs = {
    # our main package supplier
    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixpkgs-unstable";
    };

    # lix a good fork of nix
    lix = {
      url = "https://git.lix.systems/lix-project/lix/archive/main.tar.gz";

      inputs = {
        nixpkgs.follows = "nixpkgs";
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

    easy-hosts = {
      type = "github";
      owner = "isabelroses";
      repo = "easy-hosts";

      # url = "git+file:/Users/isabel/dev/easy-hosts";
    };

    ### Flake management
    # deploy systems remotely
    deploy-rs = {
      type = "github";
      owner = "serokell";
      repo = "deploy-rs";

      inputs = {
        nixpkgs.follows = "nixpkgs";
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
        nixpkgs.follows = "nixpkgs";
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
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
        darwin.follows = "";
        home-manager.follows = "";
      };
    };

    # firefox user.js
    arkenfox = {
      type = "github";
      owner = "isabelroses";
      repo = "arkenfox-nixos";
      ref = "chore-remove-fu";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "";
        pre-commit.follows = "";
      };
    };

    # Nix topology a way to generate diagrams of your nix config
    nix-topology = {
      url = "github:oddlama/nix-topology";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
        pre-commit-hooks.follows = "";
        devshell.follows = "";
      };
    };

    ### Additional packages
    # a plain simple way to host a mail server
    simple-nixos-mailserver = {
      type = "gitlab";
      owner = "simple-nixos-mailserver";
      repo = "nixos-mailserver";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-24_11.follows = "";
        flake-compat.follows = "";
      };
    };

    cosmic = {
      type = "github";
      owner = "lilyinstarlight";
      repo = "nixos-cosmic";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "";
        flake-compat.follows = "";
      };
    };

    ags = {
      type = "github";
      owner = "aylur";
      repo = "ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    homebrew = {
      type = "github";
      owner = "isabelroses";
      repo = "nix-homebrew";
      ref = "chore-drop-fu";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        nix-darwin.follows = "darwin";
      };
    };

    # my own wm
    # comfywm = {
    #   url = "git+ssh://git@git.isabelroses.com:2222/isabel/comfywm";
    #   # url = "path:/home/isabel/dev/comfywm";
    #
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # a tree-wide formatter
    treefmt-nix = {
      type = "github";
      owner = "numtide";
      repo = "treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ### misc
    # a index for nixpkgs
    nix-index-db = {
      type = "github";
      owner = "nix-community";
      repo = "nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # declarative theme management
    catppuccin = {
      type = "github";
      owner = "catppuccin";
      repo = "nix";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "";
        home-manager.follows = "";
        home-manager-stable.follows = "";
        nuscht-search.follows = "";
        catppuccin-v1_1.follows = "";
        catppuccin-v1_2.follows = "";
      };
    };

    ### my programs
    beapkgs = {
      type = "github";
      owner = "isabelroses";
      repo = "beapkgs";

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
        beapkgs.follows = "beapkgs";
      };
    };

    ivy = {
      type = "github";
      owner = "comfysage";
      repo = "ivy";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
        beapkgs.follows = "beapkgs";
      };
    };

    # exists for ".follows"
    flake-utils = {
      type = "github";
      owner = "numtide";
      repo = "flake-utils";
      inputs.systems.follows = "systems";
    };
  };
}
