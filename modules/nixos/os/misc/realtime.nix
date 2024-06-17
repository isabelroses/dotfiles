{ config, ... }:
{
  # port of https://gitlab.archlinux.org/archlinux/packaging/packages/realtime-privileges
  # see https://wiki.archlinux.org/title/Realtime_process_management
  # tldr: realtime processes have higher priority than normal processes

  users = {
    users.${config.modules.system.mainUser}.extraGroups = [ "realtime" ];
    groups.realtime = { };
  };

  services.udev.extraRules = ''
    KERNEL=="cpu_dma_latency", GROUP="realtime"
  '';

  security.pam.loginLimits = [
    {
      domain = "@realtime";
      type = "-";
      item = "rtprio";
      value = 98;
    }
    {
      domain = "@realtime";
      type = "-";
      item = "memlock";
      value = "unlimited";
    }
    {
      domain = "@realtime";
      type = "-";
      item = "nice";
      value = -11;
    }
  ];
}
