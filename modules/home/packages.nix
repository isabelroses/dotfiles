{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) types;
  inherit (lib.strings)
    escapeShellArg
    optionalString
    makeBinPath
    concatMapStringsSep
    concatMapAttrsStringSep
    ;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.attrsets) mapAttrs filterAttrs;
  inherit (lib.trivial) flip;

  module =
    { name, ... }:
    {
      freeformType = types.attrsOf types.anything;

      options = {
        enable = mkEnableOption "${name} wrapper";

        package = mkOption {
          type = types.nullOr types.package;
          default = null;
          description = ''
            The package to use for the wrapper.
          '';
        };

        flags = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = ''
            Whether to enable the wrapper.
          '';
        };

        extraWrapperFlags = mkOption {
          type = types.str;
          default = "";
          description = ''
            Extra flags to pass to the wrapper.
          '';
        };

        path = mkOption {
          type = types.listOf types.package;
          default = [ ];
          description = ''
            Binaries to add to the wrapper.
          '';
        };

        env = mkOption {
          type = types.attrsOf types.str;
          default = { };
          description = ''
            Environment variables to set in the wrapper.
          '';
        };
      };
    };

  wrappers = filterAttrs (_: attrs: attrs.enable) config.garden.wrappers;
  packages = flip mapAttrs wrappers (
    name:
    {
      package,
      flags,
      extraWrapperFlags,
      path,
      env,
      ...
    }:
    pkgs.symlinkJoin {
      inherit name;

      meta = package.meta or { } // {
        outputsToInstall = [ "out" ];
      };

      passthru = package.passthru or { } // {
        unwrapped = package;
      };

      paths = [ package ];
      nativeBuildInputs = [ pkgs.makeBinaryWrapper ];

      postBuild = ''
        wrapProgram $out/bin/${package.meta.mainProgram or name} \
          ${
            optionalString (flags != [ ]) (
              concatMapStringsSep " " (flag: "--add-flags ${escapeShellArg flag}") flags
            )
          } \
          ${optionalString (path != [ ]) "--prefix PATH : ${makeBinPath path}"} \
          ${
            optionalString (env != { }) (
              concatMapAttrsStringSep " " (name: value: "--set-default ${name} ${escapeShellArg value}") env
            )
          } \
          ${optionalString (extraWrapperFlags != "") extraWrapperFlags}
      '';
    }
  );
in
{
  options = {
    garden = {
      wrappers = mkOption {
        type = types.attrsOf (types.submodule module);
        default = { };
        description = ''
          A set of wrappers for the garden users.
        '';
      };

      packages = mkOption {
        type = types.attrsOf types.package;
        default = { };
        description = ''
          A set of packages for the garden users.
        '';
      };
    };
  };

  config.garden = {
    inherit packages;
  };
}
