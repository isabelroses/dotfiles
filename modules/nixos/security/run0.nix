{
  security = {
    run0 = {
      enable = true;

      # wheelNeedsPassword = false means wheel group can execute commands without
      # a password so just disable it
      wheelNeedsPassword = false;

      # installs run0-sudo-shim
      sudo-shim.enable = true;
    };

    # we are committed
    sudo.enable = false;
    sudo-rs.enable = false;
  };
}
