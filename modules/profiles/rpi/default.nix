{
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    (inputs.nixpkgs + "/nixos/modules/installer/sd-card/sd-image-aarch64.nix")
    (inputs.nixpkgs + "/nixos/modules/installer/sd-card/sd-image-raspberrypi.nix")
  ];

  boot = {
    kernelPackages = lib.modules.mkForce pkgs.linuxKernel.packages.linux_rpi3;

    # The last console argument in the list that linux can find at boot will receive kernel logs.
    # The serial ports listed here are:
    # - ttyS0: serial
    # - tty0: hdmi
    kernelParams = [
      "console=ttyS0,115200n8"
      "console=tty0"
    ];
  };

  # fix the following error:
  # modprobe: FATAL: Module ahci not found in directory
  # https://github.com/NixOS/nixpkgs/issues/154163#issuecomment-1350599022
  nixpkgs.overlays = [
    (_: prev: {
      makeModulesClosure = x: prev.makeModulesClosure (x // { allowMissing = true; });
    })
  ];

}
