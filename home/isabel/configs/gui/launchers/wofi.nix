{
  lib,
  defaults,
  osConfig,
  ...
}: {
  programs.wofi = lib.mkIf osConfig.modules.programs.gui.launchers.wofi.enable {
    enable = true;
    settings = {
      show = ["drun" "run"];
      layer = "top";
      location = 0;
      allow_images = true;
      image_size = 22;
      gtk_dark = true;
      terminal = defaults.terminal;
      key_expand = "Tab";
      run-always_parse_args = true;
      normal_window = false;
      insensitive = true;
    };
    style = ''
      @define-color base	#1e1e2e;
      @define-color mantle	#181825;
      @define-color text	#cdd6f4;
      @define-color surface0	#313244;
      @define-color sapphire	#74c7ec;


      window {
        margin: 0px;
        border: 2px solid @sapphire;
        background-color: alpha(@mantle, 0.6);
      }

      #input {
        margin: 5px;
        border: none;
        color: @text;
        background-color: alpha(@base, 0.7);
      }

      #inner-box {
        margin: 5px;
        border: none;
        border-radius: 5px;
        background-color: alpha(@base, 0.7);
      }

      #outer-box {
        margin: 5px;
        border: none;
        background-color: alpha(@mantle, 0.0);
      }

      #scroll {
        margin: 0px;
        border: none;
      }

      #text {
        margin: 5px;
        border: none;
        color: @text;
      }

      #entry:selected {
        background-color: alpha(@surface0, 0.7);
      }
    '';
  };
}
