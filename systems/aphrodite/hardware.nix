{
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/ecbc167c-3bfe-4801-90c1-51c272d316c6";
    fsType = "ext4";
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/a04ef6f2-82fe-4a8c-9273-fb80e7383dfa"; }
  ];
}
