{ lib, pkgs, ... }:
{
  # use networkmanager in the live environment
  networking.networkmanager.enable = lib.mkForce true;
  networking.wireless.enable = lib.mkForce false;

  # allow ssh into the system for headless installs
  systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDZmzCZrKIdTSUf1GFWB9bF2nDRfjdWI4+jfcZbsscsSdNHBBaYnDjQftj8lVUMmSzjKasIeU3yKmuai6t2GBnIfxZq+5L/uvIZhYfgJwcjhLkXZL2CCG1UtxFV6Gwe2RJWA7VrGzhfU+Kjx6O7oCKlwy0M6cknUU+G17rqoGlOwDtMiDR+as6UoxeEf//xIdvBdEb3A+JGo4WVx1+/8XedKM5ngyY0zH6vKb12kudVMjJsqQ4cES8JozuL4LMEExsPRALPVGYQ69ulMLl4zkbbP2Ne5UO9Uf/BsBF2DJU3uWVIG6nAUIeNr4NXaa7h4/cnlpP+f4H/7MvOeif85TYU2WK+yiy11z7N6wxbB1/Mtq2sMldMq3Csb7A0GkeF1qXazG0yp4Oa0sene0JfPI3AsYSFOHuByVRkb6kI3f+d/xogwoLJ645olZLcobsqWoS4TQZHj44CTRseXzCQiUGBKV9Bb/7hqY7TbcwRd7cEW91lbXIzO6PUDhi1E59VqYE= isabel"
  ];
}
