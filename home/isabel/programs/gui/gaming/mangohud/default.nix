{
  lib,
  osConfig,
  ...
}: {
  config = lib.mkIf osConfig.modules.programs.gaming.mangohud.enable {
    programs.mangohud = {
      enable = true;
      settings = {
        fps_limit = "60,0";
        vsync = 1;
        cpu_stats = true;
        cpu_temp = true;
        gpu_stats = true;
        gpu_temp = true;
        vulkan_driver = true;
        fps = true;
        frametime = true;
        frame_timing = true;
        enableSessionWide = true;
        font_size = 24;
        position = "top-right";
        engine_version = true;
        wine = true;
        no_display = true;
        background_alpha = "0.5";
        toggle_hud = "Shift_R+F12";
        toggle_fps_limit = "Shift_R+F1";
      };
    };
  };
}
