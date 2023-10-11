{config, ...}: let
  sys = config.modules.system;
in {
  security = {
    # system audit
    auditd.enable = sys.security.auditd.enable;
    audit = {
      enable = sys.security.auditd.enable;
      backlogLimit = 8192;
      failureMode = "printk";
      rules = [
        "-a exit,always -F arch=b64 -S execve"
      ];
    };
  };
}
