# just use run0
{
  security = {
    sudo.enable = false;

    run0 = {
      enable = true;
      wheelNeedsPassword = false;
    };
  };
}
