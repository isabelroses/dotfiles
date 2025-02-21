{
  imports = [
    ../../systems # the host systems configurations

    ./checks # custom checks that are devised to test if the system is working as expected
    ./lib # the lib that is used in the system
    ./modules.nix # nixos and home-manager modules
    ./packages # our custom packages provided by the flake
    ./programs # programs that run in the dev shell

    ./args.nix # the base args that is passed to the flake
  ];

  config.flake.nixConfig = {
    extra-experimental-features = [ "pipe-operators" ];
    extra-substituters = [
      "https://nix-community.cachix.org" # nix-community cache
      "https://isabelroses.cachix.org" # precompiled binarys from flake
      "https://catppuccin.cachix.org" # a cache for all catppuccin ports
      "https://cosmic.cachix.org" # for the cosmic desktop
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "isabelroses.cachix.org-1:mXdV/CMcPDaiTmkQ7/4+MzChpOe6Cb97njKmBQQmLPM="
      "catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="
      "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
    ];
  };
}
