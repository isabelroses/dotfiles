{
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/4d503c5f-c51a-4eca-993c-5beb9b85b963";
    fsType = "ext4";
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/9455e246-4f8f-42cb-beb8-d1a071a1b5e0"; }
  ];
}
