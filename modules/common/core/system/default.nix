_: {
  imports = [
    ./hardware # hardware - i.e bluetooth, sound, tpm etc.
    ./media # enable multimedia
    ./network # networking & tcp optimizations
    ./boot # boot and bootloader configurations
    ./os # system configurations
    ./smb # host and recive smb shares
    ./activation # activation system for nixos-rebuild
    ./virtualization # hypervisor and virtualisation related options - docker, QEMU, waydroid etc.
  ];
}
