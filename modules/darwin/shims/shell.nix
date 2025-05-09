# this shim ensures that the Darwin has `defaultUserShell` such that a noshell
# can work
{ lib, config, ... }:
let
  inherit (lib)
    mkDefault
    mkOption
    types
    literalExpression
    genAttrs
    ;
in
{
  options = {
    users.defaultUserShell = mkOption {
      description = ''
        This option defines the default shell assigned to user
        accounts. This can be either a full system path or a shell package.

        This must not be a store path, since the path is
        used outside the store (in particular in /etc/passwd).
      '';
      example = literalExpression "pkgs.zsh";
      type = types.either types.path types.shellPackage;
    };
  };

  config = {
    users.users = genAttrs config.garden.system.users (_: {
      shell = mkDefault config.users.defaultUserShell;
    });
  };
}
