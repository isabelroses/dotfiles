{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types mkIf;
in {
  config = mkIf config.modules.system.encryption.enable {
    warnings =
      if config.modules.system.encryption.device == ""
      then [
        ''
          You have enabled LUKS encryption, but have not selected a device, you may not be able to decrypt your disk on boot.
        ''
      ]
      else [];
  };
  options.modules.system.encryption = {
    enable = mkEnableOption "LUKS encryption";

    device = mkOption {
      type = types.str; # this should actually be a list
      default = "";
      description = ''
        The LUKS label for the device that will be decrypted on boot.
        Currently does not support multiple devices at once.
      '';
    };

    keyFile = mkOption {
      type = with types; nullOr str;
      default = null;
      description = ''
        The path to the keyfile that will be used to decrypt the device.
        Needs to be an absolute path, and the file must exist. Set to `null`
        to disable.
      '';
    };

    keySize = mkOption {
      type = types.int;
      default = 4096;
      description = ''
        The size of the keyfile in bytes.
      '';
    };

    fallbackToPassword = mkOption {
      type = types.bool;
      default = !config.boot.initrd.systemd.enable;
      description = ''
        Whether or not to fallback to password authentication if the keyfile
        is not present.
      '';
    };
  };
}
