{ lib, config, ... }:
let
  inherit (lib) mkEnableOption mkDefault;

  cfg = config.garden.system.boot;
in
{
  options.garden.system.boot = {
    tmpOnTmpfs =
      mkEnableOption "`/tmp` living on tmpfs. false means it will be cleared manually on each reboot"
      // {
        default = true;
      };
  };

  # if you have a lack of ram, you should avoid tmpfs to prevent hangups while compiling
  config.boot.tmp = {
    # /tmp on tmpfs, lets it live on your ram
    useTmpfs = cfg.tmpOnTmpfs;

    # If not using tmpfs, which is naturally purged on reboot, we must clean
    # we have to clean /tmp
    cleanOnBoot = mkDefault (!config.boot.tmp.useTmpfs);

    # this defaults to 50% of your ram
    # but i want to build code sooo
    # tmpfsSize = mkDefault "75%";

    # enable huge pages on tmpfs for better performance
    tmpfsHugeMemoryPages = "within_size";
  };
}
