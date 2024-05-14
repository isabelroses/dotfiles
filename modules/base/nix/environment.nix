{ pkgs, inputs, ... }:
{
  environment = {
    etc = with inputs; {
      # set channels (backwards compatibility)
      "nix/flake-channels/system".source = self;
      "nix/flake-channels/nixpkgs".source = nixpkgs;
      "nix/flake-channels/home-manager".source = home-manager;

      # preserve current flake in /etc
      "nixos/flake".source = self;
    };

    # git is required for flakes, and cachix for binary substituters
    systemPackages = with pkgs; [
      git
      cachix
    ];
  };
}
