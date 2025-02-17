{
  description = "Isabel's dotfiles";

  outputs =
    inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } { imports = [ ./modules/flake ]; };

  inputs = {
    # our main package supplier
    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixpkgs-unstable";
      # ref = "1da52dd49a127ad74486b135898da2cef8c62665";
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
      owner = "isabelroses";
      repo = "nix-darwin";
      ref = "tools";
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
      };
    };

    # manage userspace with nix
    home-manager = {
      type = "github";
      owner = "nix-community";
      repo = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
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
      owner = "tgirlcloud";
      repo = "easy-hosts";

      # url = "git+file:/Users/isabel/dev/easy-hosts";
    };

    ### Flake management
    # deploy systems remotely
    deploy-rs = {
      type = "github";
      owner = "isabelroses";
      repo = "deploy-rs";
      ref = "no-fu";

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

    homebrew = {
      type = "github";
      owner = "zhaofengli";
      repo = "nix-homebrew";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        nix-darwin.follows = "darwin";
      };
    };

    # a tree-wide formatter
    treefmt-nix = {
      type = "github";
      owner = "numtide";
      repo = "treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ### misc
    # declarative theme management
    catppuccin = {
      type = "github";
      owner = "Lichthagel";
      repo = "catppuccin-nix";
      ref = "feat/gitea-forgejo";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    evergarden = {
      type = "github";
      owner = "comfysage";
      repo = "evergarden";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ### my programs
    beapkgs = {
      type = "github";
      owner = "tgirlcloud";
      repo = "beapkgs";

      # url = "git+file:/home/isabel/dev/tgirlcloud/beapkgs";

      inputs.nixpkgs.follows = "nixpkgs";
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

    # transative deps
    systems = {
      type = "github";
      owner = "nix-systems";
      repo = "default";
    };
  };
}
