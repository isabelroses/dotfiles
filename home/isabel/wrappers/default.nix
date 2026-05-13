{
  lib,
  pkgs,
  self,
  self',
  config,
  inputs,
  inputs',
  ...
}:
{
  users.users.isabel.packages =
    builtins.attrValues
      (inputs.wrappers.lib {
        inherit lib pkgs;
        modules = [ ./all-modules.nix ];
        specialArgs = {
          inherit
            self
            self'
            inputs
            inputs'
            ;
          osConfig = config;
        };
      }).build.packages;
}
