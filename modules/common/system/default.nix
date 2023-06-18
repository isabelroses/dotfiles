_: {
  imports = [
    # module is the skeleton that adds all nixos options for the rest of the imports
    ./module

    ./display # display protocol (wayland/xorg)
    ./hardware # hardware - i.e bluetooth, sound, tpm etc.
    ./media # enable multimedia
    ./networking # tcp optimizations
    ./boot # boot and bootloader configurations
  ];
}
