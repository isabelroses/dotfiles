{
  lib,
  self,
  config,
  inputs',
  ...
}:
let
  inherit (lib) mkIf;
  inherit (self.lib) anyHome;

  cond = anyHome config (conf: conf.programs.fht-compositor.enable or false);
in
{
  config = mkIf cond {
    services.displayManager.sessionPackages = [ inputs'.fht-compositor.packages.default ];
  };
}
