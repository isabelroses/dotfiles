{
  # keyboard settings is not very useful on macOS
  # the most important thing is to remap option key to alt key globally,
  # but it's not supported by macOS yet.
  system = {
    keyboard = {
      enableKeyMapping = true; # enable key mapping so that we can use `option` as `control`

      # NOTE: do NOT support remap capslock to both control and escape at the same time
      remapCapsLockToControl = false; # remap caps lock to control
      remapCapsLockToEscape = true; # remap caps lock to escape

      # swap left command and left alt
      # so it matches common keyboard layout: `ctrl | command | alt`
      # disabled as it only causes problems
      swapLeftCommandAndLeftAlt = false;
    };

    defaults.NSGlobalDomain = {
      # Use F1, F2, etc. keys as standard function keys.
      "com.apple.keyboard.fnState" = true;

      AppleKeyboardUIMode = 3; # Mode 3 enables full keyboard control.

      ApplePressAndHoldEnabled = false; # enable press and hold
      # If you press and hold certain keyboard keys when in a text area, the key’s character begins to repeat.
      # This is very useful for vim users, they use `hjkl` to move cursor.
      # sets how long it takes before it starts repeating.
      InitialKeyRepeat = 15; # normal minimum is 15 (225 ms), maximum is 120 (1800 ms)
      # sets how fast it repeats once it starts.
      KeyRepeat = 3; # normal minimum is 2 (30 ms), maximum is 120 (1800 ms)
    };
  };
}
