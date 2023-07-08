_: {
  imports = [
    ./display # display protocol (wayland/xorg)
    ./hardware # hardware - i.e bluetooth, sound, tpm etc.
    ./media # enable multimedia
    ./networking # tcp optimizations
    ./boot # boot and bootloader configurations
  ];
}
