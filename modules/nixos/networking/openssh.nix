{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib) mkMerge;
  inherit (self.lib) mkPubs;
in
{
  boot.initrd.network.ssh.authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMQDiHbMSinj8twL9cTgPOfI6OMexrTZyHX27T8gnMj2"
  ];

  services.openssh = {
    enable = true;
    startWhenNeeded = true;

    allowSFTP = true;

    banner = ''
      Connected to ${config.system.name} @ ${config.system.configurationRevision}

      All conntections to this server are logged. Please disconnect now if you
      are not permitted access.
    '';

    settings = {
      # Don't allow root login
      PermitRootLogin = "no";

      # only allow key based logins and not password
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      AuthenticationMethods = "publickey";
      PubkeyAuthentication = "yes";
      ChallengeResponseAuthentication = "no";
      UsePAM = false;

      UseDns = false;
      X11Forwarding = false;

      # Use key exchange algorithms recommended by `nixpkgs#ssh-audit`
      KexAlgorithms = [
        "curve25519-sha256"
        "curve25519-sha256@libssh.org"
        "diffie-hellman-group16-sha512"
        "diffie-hellman-group18-sha512"
        "sntrup761x25519-sha512@openssh.com"
        "diffie-hellman-group-exchange-sha256"
        "mlkem768x25519-sha256"
        "sntrup761x25519-sha512"
      ];

      # Use Macs recommended by `nixpkgs#ssh-audit`
      Macs = [
        "hmac-sha2-512-etm@openssh.com"
        "hmac-sha2-256-etm@openssh.com"
        "umac-128-etm@openssh.com"
      ];

      # kick out inactive sessions
      ClientAliveCountMax = 5;
      ClientAliveInterval = 60;
    };

    openFirewall = true;
    # the port(s) openssh daemon should listen on
    ports = [ 22 ];

    hostKeys = [
      {
        bits = 4096;
        path = "/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
      }
      {
        bits = 4096;
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];

    # find these with `ssh-keyscan <hostname>`
    knownHosts = mkMerge [
      (mkPubs "github.com" [
        {
          type = "rsa";
          key = "AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==";
        }
        {
          type = "ed25519";
          key = "AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
        }
      ])

      (mkPubs "gitlab.com" [
        {
          type = "rsa";
          key = "AAAAB3NzaC1yc2EAAAADAQABAAABAQCsj2bNKTBSpIYDEGk9KxsGh3mySTRgMtXL583qmBpzeQ+jqCMRgBqB98u3z++J1sKlXHWfM9dyhSevkMwSbhoR8XIq/U0tCNyokEi/ueaBMCvbcTHhO7FcwzY92WK4Yt0aGROY5qX2UKSeOvuP4D6TPqKF1onrSzH9bx9XUf2lEdWT/ia1NEKjunUqu1xOB/StKDHMoX4/OKyIzuS0q/T1zOATthvasJFoPrAjkohTyaDUz2LN5JoH839hViyEG82yB+MjcFV5MU3N1l1QL3cVUCh93xSaua1N85qivl+siMkPGbO5xR/En4iEY6K2XPASUEMaieWVNTRCtJ4S8H+9";
        }
        {
          type = "ed25519";
          key = "AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf";
        }
      ])

      (mkPubs "codeberg.org" [
        {
          type = "rsa";
          key = "AAAAB3NzaC1yc2EAAAADAQABAAABAQC8hZi7K1/2E2uBX8gwPRJAHvRAob+3Sn+y2hxiEhN0buv1igjYFTgFO2qQD8vLfU/HT/P/rqvEeTvaDfY1y/vcvQ8+YuUYyTwE2UaVU5aJv89y6PEZBYycaJCPdGIfZlLMmjilh/Sk8IWSEK6dQr+g686lu5cSWrFW60ixWpHpEVB26eRWin3lKYWSQGMwwKv4LwmW3ouqqs4Z4vsqRFqXJ/eCi3yhpT+nOjljXvZKiYTpYajqUC48IHAxTWugrKe1vXWOPxVXXMQEPsaIRc2hpK+v1LmfB7GnEGvF1UAKnEZbUuiD9PBEeD5a1MZQIzcoPWCrTxipEpuXQ5Tni4mN";
        }
        {
          type = "ed25519";
          key = "AAAAC3NzaC1lZDI1NTE5AAAAIIVIC02vnjFyL+I4RHfvIGNtOgJMe769VTF1VR4EB3ZB";
        }
      ])

      (mkPubs "git.sr.ht" [
        {
          type = "rsa";
          key = "AAAAB3NzaC1yc2EAAAADAQABAAABAQDZ+l/lvYmaeOAPeijHL8d4794Am0MOvmXPyvHTtrqvgmvCJB8pen/qkQX2S1fgl9VkMGSNxbp7NF7HmKgs5ajTGV9mB5A5zq+161lcp5+f1qmn3Dp1MWKp/AzejWXKW+dwPBd3kkudDBA1fa3uK6g1gK5nLw3qcuv/V4emX9zv3P2ZNlq9XRvBxGY2KzaCyCXVkL48RVTTJJnYbVdRuq8/jQkDRA8lHvGvKI+jqnljmZi2aIrK9OGT2gkCtfyTw2GvNDV6aZ0bEza7nDLU/I+xmByAOO79R1Uk4EYCvSc1WXDZqhiuO2sZRmVxa0pQSBDn1DB3rpvqPYW+UvKB3SOz";
        }
        {
          type = "ed25519";
          key = "AAAAC3NzaC1lZDI1NTE5AAAAIMZvRd4EtM7R+IHVMWmDkVU3VLQTSwQDSAvW0t2Tkj60";
        }
      ])

      (mkPubs "git.isabelroses.com" [
        {
          type = "rsa";
          key = "AAAAB3NzaC1yc2EAAAADAQABAAABgQCcQrSjsd9ZUdT5co+JfeErQbRGBIjxPlouGuS9vq1xwi2twJ8iQkZ8uEwaTVFbru3IQSxIbeTtvorXlHdPDewWvTaXQdL0TvtrB/okc77cyHcuJxyN/OCW2FEfOPXwmC/cAJYGXbc1mul866k79h/GjQECRfO3wuENk1p6TynxRAS38nKCw5zY/XYY9CcSxb0yvv8luhCAD45cc5VImTsiphHWGDDwcD3/4xdml64fWKFo5Cc5AqaL3DQbrPMgB6B5JqtZTq5yN4JfjwpzzDFha6gAmtB5f7Fd2nIoBWa44FSnlIMACmOqlr0nqrtuvLMBaWxV6oJrW85jiQ/qaFSj8UextBjyg062qaZ1EHlqGrlOMyIqk6sgQ0mgEFcyH2vPcqVJRp8Wh6DVX5cQkNRNeDDcq5WmcxY7eWZyZCnYRkRPEcdk6X/xxWUY5aDy3fCEJV7HjcvPW7/9ERduAe1e2/3YHbIkGTv8OUIEWL8Z/Ai8lnQ+GZdrTr/Jjssilmk=";
        }
        {
          type = "ed25519";
          key = "AAAAC3NzaC1lZDI1NTE5AAAAIFluIN96lPhNvf2JsA2E+HjuQbDseD2sQJOgQbspJWW0";
        }
      ])

      (mkPubs "git.auxolotl.com" [
        {
          type = "rsa";
          key = "AAAAB3NzaC1yc2EAAAADAQABAAACAQCd21dQk5Hx5hqMV7KEVm/qCk++jXGp1fOyoPHM0k5Ostdxp3P0DYvzLppud2lYZ3r69qkYVLFjHREHac0UVWKQ2A08T761y53aNlSfRlp/cbN1lAH29HjgLWt4KBFu/gYUrEnXU7rs9JU17N0rS7oW5R+G4RX3dOSPcx7V9RToJ7wHeOeuKhyoFI6bjJfflNPZWKIHk5QFtblyUUnCnuFZvZtq1y7CzB6YPm4wN209yEwVYORovz2maX2hoEEFn1k1DoGaxXtsaIbYFq0DBgrl4302SV9JwLlItpJX8e47owd1Y7mS7riFDTtmiE2IMiCV4tY0n0VMgo3soHKoTbgkG8bCIGWgTQLBBMICnqbz9m8SMvG8dIrN5GBhIMImz4BU+Gq2uqqIfx2DjzpMlMl05qnM4+LcMWeoPloLlxMFB5TSimLxyYOQ6hwj+hSpwBJ1Nt1zUNAM8ZBKKATKkx+FtW58mRN+ByT5iWbofHwJT+xaYcVDQQodgnEIdnNLdB25b60qeo/iHyz6DAAHmHXFCHluIKMlamXCa5myEluhxc8Hy+ddPLqKpQFj/z6vM28Uejy5xKLsndJhcaAS5L30xp7CukSzjYkNb1q/kuNyfVQSmBkahkKIOtjrqad80BWVHdiIbC0sEHX/RC5G6/mePqFQI5aR8eTbIWOITLdh8Q==";
        }
        {
          type = "ed25519";
          key = "AAAAC3NzaC1lZDI1NTE5AAAAIM4rfWCoqby2qIcq/KVEWCKZVvIxr6h4GxJcsCQYffj+";
        }
      ])
    ];
  };
}
