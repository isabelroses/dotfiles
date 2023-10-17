{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  device = config.modules.device;
in {
  config = mkIf (device.gpu == "intel" || device.gpu == "hybrid-nv") {
    # enable the i915 kernel module
    boot.initrd.kernelModules = ["i915"];
    # better performance than the actual Intel driver
    services.xserver.videoDrivers = ["modesetting"];

    nixpkgs.config.packageOverrides = pkgs: {
      # let me play youtube videos without h.264, please and thank you
      vaapiIntel = pkgs.vaapiIntel.override {enableHybridCodec = true;};
    };

    # OpenCL support and VAAPI
    hardware.opengl = {
      extraPackages = with pkgs; [
        intel-compute-runtime
        intel-media-driver
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
      ];

      extraPackages32 = with pkgs.pkgsi686Linux; [
        # intel-compute-runtime # FIXME does not build due to unsupported system
        intel-media-driver
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
      ];
    };

    environment.variables = mkIf (config.hardware.opengl.enable && device.gpu != "hybrid-nv") {
      VDPAU_DRIVER = "va_gl";
    };
  };
}
