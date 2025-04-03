# keep up to date with our "base" config
{ config, ... }:
{
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowAliases = false;
    };

    overlays = [
      (_: prev: {
        nixVersions.stable = config.nix.package;
        nixForLinking = prev.nixVersions.stable;
      })
    ];
  };
}
