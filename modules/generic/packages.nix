{
  lib,
  config,
  _class,
  ...
}:
let
  inherit (lib) mkOption mergeAttrsList optionalAttrs;
  inherit (lib.types) attrsOf package;
in
{
  options.garden.packages = mkOption {
    type = attrsOf package;
    default = { };
    description = ''
      A set of packages to install in the garden environment.
    '';
  };

  config = mergeAttrsList [
    (optionalAttrs (_class == "nixos" || _class == "darwin") {
      environment.systemPackages = builtins.attrValues config.garden.packages;
    })

    (optionalAttrs (_class == "homeManager") {
      home.packages = builtins.attrValues config.garden.packages;
    })
  ];
}
