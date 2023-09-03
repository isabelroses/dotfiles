{lib, config, ...}: {
  config = {
    services.smartd.enable = lib.mkForce false; #Unavailable - device lacks SMART capability.

    zramSwap.enable = true;
    services.openssh.enable = true;
    users.users.root.openssh.authorizedKeys.keys = [
      ''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDZmzCZrKIdTSUf1GFWB9bF2nDRfjdWI4+jfcZbsscsSdNHBBaYnDjQftj8lVUMmSzjKasIeU3yKmuai6t2GBnIfxZq+5L/uvIZhYfgJwcjhLkXZL2CCG1UtxFV6Gwe2RJWA7VrGzhfU+Kjx6O7oCKlwy0M6cknUU+G17rqoGlOwDtMiDR+as6UoxeEf//xIdvBdEb3A+JGo4WVx1+/8XedKM5ngyY0zH6vKb12kudVMjJsqQ4cES8JozuL4LMEExsPRALPVGYQ69ulMLl4zkbbP2Ne5UO9Uf/BsBF2DJU3uWVIG6nAUIeNr4NXaa7h4/cnlpP+f4H/7MvOeif85TYU2WK+yiy11z7N6wxbB1/Mtq2sMldMq3Csb7A0GkeF1qXazG0yp4Oa0sene0JfPI3AsYSFOHuByVRkb6kI3f+d/xogwoLJ645olZLcobsqWoS4TQZHj44CTRseXzCQiUGBKV9Bb/7hqY7TbcwRd7cEW91lbXIzO6PUDhi1E59VqYE=''
    ];

    boot = {
      growPartition = !config.boot.initrd.systemd.enable;
      kernelParams = ["net.ifnames=0"];
      kernel = {
        sysctl = {
          "net.ipv4.ip_forward" = true;
          "net.ipv6.conf.all.forwarding" = true;
        };
      };

      loader.grub = {
        enable = true;
        useOSProber = lib.mkForce false;
        efiSupport = lib.mkForce false;
        enableCryptodisk = false;
        theme = null;
        backgroundColor = null;
        splashImage = null;
        device = lib.mkForce "/dev/sda";
      };
    };
  };
}
