{config, ...}: let
  cfg = config.modules.system.security;
in {
  security = {
    # system audit
    auditd.enable = cfg.auditd.enable;
    audit = {
      enable = cfg.auditd.enable;
      backlogLimit = 8192;
      failureMode = "printk";
      rules = [
        "-a exit,always -F arch=b64 -S execve"
      ];
    };
  };
}
