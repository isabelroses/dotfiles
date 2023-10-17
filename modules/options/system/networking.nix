{lib, ...}:
with lib; {
  options.modules.system.networking = {
    optimizeTcp = mkEnableOption "Enable tcp optimizations";
  };
}
