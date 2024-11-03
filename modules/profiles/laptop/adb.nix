{
  config.services.udev.extraRules = ''
    # add my android device to adbusers
    SUBSYSTEM=="usb", ATTR{idVendor}=="04e8", MODE="0666", GROUP="adbusers"
  '';
}
