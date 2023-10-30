{lib, ...}: let
  inherit (lib) mkOption types;
in {
  options.modules.programs = {
    git = {
      signingKey = mkOption {
        type = types.str;
        default = "";
        description = "The default gpg key used for signing commits";
      };
    };
  };
}
