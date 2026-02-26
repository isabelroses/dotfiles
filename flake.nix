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

    # improved support for darwin
    darwin = {
      type = "github";
      owner = "isabelroses";
      repo = "nix-darwin";
      ref = "darwin-rebuild";
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
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets, shhh
    sops = {
      type = "github";
      owner = "Mic92";
      repo = "sops-nix";
      ref = "pull/779/merge";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ### Additional packages
    # a plain simple way to host a mail server
    simple-nixos-mailserver = {
      type = "gitlab";
      owner = "simple-nixos-mailserver";
      repo = "nixos-mailserver";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        git-hooks.follows = "";
        flake-compat.follows = "";
        blobs.follows = "";
      };
    };

    homebrew = {
      type = "github";
      owner = "zhaofengli";
      repo = "nix-homebrew";
      inputs.brew-src.follows = "";
    };

    spicetify = {
      type = "github";
      owner = "Gerg-L";
      repo = "spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hostling = {
      type = "github";
      owner = "BatteredBunny";
      repo = "hostling";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tranquil = {
      url = "git+https://tangled.org/tranquil.farm/tranquil-pds";
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
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
