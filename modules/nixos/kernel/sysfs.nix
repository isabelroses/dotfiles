{
  boot.kernel.sysfs = {
    kernel.mm.transparent_hugepage = {
      enabled = "always";
      defrag = "defer";
      shmem_enabled = "within_size";
    };
  };
}
