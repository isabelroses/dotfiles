_: {
  imports = [
    ./activation # activation system for nixos-rebuild
    ./boot # boot and bootloader configurations
    ./emulation # emulation setup to fix QEMU issues
    ./encryption # just let me hide my stuff stop asking questions
    ./hardware # hardware - i.e bluetooth, sound, tpm etc.
    ./media # enable multimedia
    ./os # system configurations
    ./security # keeping the system safe
    ./smb # host and recive smb shares
    ./virtualization # hypervisor and virtualisation related options - docker, QEMU, waydroid etc.
  ];
}
