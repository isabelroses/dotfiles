{
  config,
  inputs',
  ...
}:
{
  programs.hyfetch = {
    inherit (config.garden.profiles.workstation) enable;
    package = inputs'.tgirlpkgs.packages.hyfetch;
  };
}
