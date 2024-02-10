{
  # keyboard settings is not very useful on macOS
  # the most important thing is to remap option key to alt key globally,
  # but it's not supported by macOS yet.
  system.defaults.keyboard = {
    enableKeyMapping = true; # enable key mapping so that we can use `option` as `control`

    # NOTE: do NOT support remap capslock to both control and escape at the same time
    remapCapsLockToControl = false; # remap caps lock to control
    remapCapsLockToEscape = true; # remap caps lock to escape

    # swap left command and left alt
    # so it matches common keyboard layout: `ctrl | command | alt`
    # disabled as it only causes problems
    swapLeftCommandAndLeftAlt = false;
  };
}
