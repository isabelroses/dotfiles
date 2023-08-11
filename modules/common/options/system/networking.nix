{
  lib,
  ...
}:
with lib; {
  # should we optimize tcp networking
  options.modules.system.networking = {
    optimizeTcp = mkEnableOption "Enable tcp optimizations";
  };
}
