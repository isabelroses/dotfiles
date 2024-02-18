{
  # fixes "too many open files"
  security.pam.loginLimits = [
    {
      domain = "*";
      item = "nofile";
      type = "-";
      value = "65536";
    }
  ];

  # fix annoying warning
  environment.etc."mdadm.conf".text = ''
    MAILADDR root
  '';

  # prevent nix flake check from providing a warning
  system.stateVersion = "23.11";

  # provide all hardware drivers, including proprietary ones
  hardware.enableRedistributableFirmware = true;
}
