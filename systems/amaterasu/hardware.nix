{
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/3a898325-08a7-4f9f-ab19-380765bcaf92";
      fsType = "btrfs";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/36A9-4288";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/55606623-362b-4c53-a9da-26ea202aff23"; }
  ];

  # https://bbs.archlinux.org/viewtopic.php?id=287947
  boot.kernelParams = [
    "rtw89_core.disable_ps_mode=1"
    "rtw89_pci.disable_aspm_l1=1"
    "rtw89_pci.disable_aspm_l1ss=1"
    "rtw89_pci.disable_clkreq=1"
  ];
}
