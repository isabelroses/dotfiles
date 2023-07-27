_: {
  imports = [
    ./display # display protocol (wayland/xorg)
    ./hardware # hardware - i.e bluetooth, sound, tpm etc.
    ./media # enable multimedia
    ./network # networking & tcp optimizations
    ./boot # boot and bootloader configurations
    ./os # system configurations
    ./smb # host and recive smb shares
  ];
}
