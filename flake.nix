{
  description = "isabel's dotfiles";

  outputs = inputs: import ./modules/flake inputs;

  inputs = {
    # our main package supplier
    #
    # you may also notice that I don't use a `github:` url for nixpkgs this is
    # this is because it save a massive 15mb, is faster than github and if I
    # cared about command-not-found it would fix that
    #
    # See also:
    # - https://nix.dev/manual/nix/stable/protocols/tarball-fetcher#lockable-http-tarball-protocol
    # - http://web.archive.org/web/20250806225139/https://nix.dev/manual/nix/2.28/protocols/tarball-fetcher#lockable-http-tarball-protocol
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";

    # lix a good fork of nix, but also patched with my stuff
    # so really you want: https://git.lix.systems/lix-project/lix/archive/main.tar.gz
    izlix = {
      type = "github";
      owner = "isabelroses";
      repo = "izlix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
    extersia = {
      type = "github";
      owner = "extersia-org";
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
