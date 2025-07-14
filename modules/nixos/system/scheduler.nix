{ pkgs, config, ... }:
{
  services.scx = {
    inherit (config.garden.profiles.workstation) enable;
    scheduler = "scx_bpfland";
    package = pkgs.scx.rustscheds;
  };
}
