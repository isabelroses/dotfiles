{
  description = "Isabel's dotfiles";

  outputs =
    inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } { imports = [ ./modules/flake ]; };

  inputs = {
    # our main package supplier
    #
    # you may also notice that I don't use a `github:` url for nixpkgs this is
    # beacuse we can save 15mb of data by using the channel tarball this is not
    # a major saving but it is nice to have
    # https://deer.social/profile/did:plc:mojgntlezho4qt7uvcfkdndg/post/3loogwsoqok2w
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";

    # lix a good fork of nix, but also patched with my stuff
    # so really you want: https://git.lix.systems/lix-project/lix/archive/main.tar.gz
    izlix = {
      type = "github";
      owner = "isabelroses";
      repo = "izlix";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        nix_2_18.follows = "";
        pre-commit-hooks.follows = "";
        nix2container.follows = "";
        flake-compat.follows = "";
      };
    };

    # improved support for darwin
    darwin = {
      type = "github";
      owner = "nix-darwin";
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
      };
    };

    # manage userspace with nix
    home-manager = {
      type = "github";
      owner = "nix-community";
      repo = "home-manager";
      ref = "pull/4976/merge";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ### Flake management
    # bring all the mess together with flake-parts
    flake-parts = {
      type = "github";
      owner = "hercules-ci";
      repo = "flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # easily manage our hosts
    easy-hosts = {
      type = "github";
      owner = "tgirlcloud";
      repo = "easy-hosts";

      # url = "git+file:/Users/isabel/dev/easy-hosts";
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
    # TODO: https://github.com/ryantm/agenix/pull/255
    agenix = {
      type = "github";
      owner = "ryantm";
      repo = "agenix";
      ref = "pull/255/merge";

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
        nixpkgs-25_05.follows = "";
        git-hooks.follows = "";
        flake-compat.follows = "";
        blobs.follows = "";
      };
    };

    fht-compositor = {
      type = "github";
      owner = "nferhat";
      repo = "fht-compositor";
      ref = "feat-ipc";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        rust-overlay.follows = "";
      };
    };

    homebrew = {
      type = "github";
      owner = "zhaofengli";
      repo = "nix-homebrew";
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
      owner = "catppuccin";
      repo = "nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    evergarden = {
      type = "github";
      owner = "everviolet";
      repo = "nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ### my programs
    tgirlpkgs = {
      type = "github";
      owner = "tgirlcloud";
      repo = "pkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    izvim = {
      type = "github";
      owner = "isabelroses";
      repo = "nvim";

      inputs = {
        nixpkgs.follows = "";
        systems.follows = "";
      };
    };

    ivy = {
      type = "github";
      owner = "comfysage";
      repo = "ivy";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
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
