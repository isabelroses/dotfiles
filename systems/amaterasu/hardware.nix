{
  disko.devices.disk = {
    main = {
      type = "disk";
      device = "/dev/nvme1n1";
      content = {
        type = "gpt";
        partitions = {
          esp = {
            label = "esp";
            start = "1M";
            end = "128M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };

          root = {
            label = "root";
            start = "128MiB";
            end = "-8GiB";
            content = {
              type = "btrfs";
              mountpoint = "/";
              mountOptions = [
                "compress=zstd"
                "noatime"
              ];
            };
          };

          swap = {
            label = "swap";
            start = "-8GiB";
            end = "100%";
            content = {
              type = "swap";
            };
          };
        };
      };
    };
  };
}
