_: ''
  @define-color base #1e1e2e;
  @define-color mantle #181825;
  @define-color crust #11111b;

  @define-color text #cdd6f4;
  @define-color subtext0 #a6adc8;
  @define-color subtext1 #bac2de;

  @define-color surface0 #313244;
  @define-color surface1 #45475a;
  @define-color surface2 #585b70;

  @define-color overlay0 #6c7086;
  @define-color overlay1 #7f849c;
  @define-color overlay2 #9399b2;

  @define-color blue #89b4fa;
  @define-color lavender #b4befe;
  @define-color sapphire #74c7ec;
  @define-color sky #89dceb;
  @define-color teal #94e2d5;
  @define-color green #a6e3a1;
  @define-color yellow #f9e2af;
  @define-color peach #fab387;
  @define-color maroon #eba0ac;
  @define-color red #f38ba8;
  @define-color mauve #cba6f7;
  @define-color pink #f5c2e7;
  @define-color flamingo #f2cdcd;
  @define-color rosewater #f5e0dc;

  @define-color white #ffffff;

  * {
      border: none;
      border-radius: 0;
      font-family: CommitMono, monospace, Noto Sans CJK JP;
      font-weight: normal;
      font-size: 14px;
      min-height: 0;
  }

  window#waybar {
      background: rgba(21, 18, 27, 0);
      color: #cdd6f4;
  }

  tooltip {
      background: #1e1e2e;
      border-radius: 10px;
      border-width: 2px;
      border-style: solid;
      border-color: #11111b;
  }

  #workspaces button {
      padding: 5px;
      color: #313244;
      margin-right: 5px;
  }

  #workspaces button.active {
      color: #a6adc8;
  }

  #workspaces button.focused {
      color: #a6adc8;
      background: #eba0ac;
      border-radius: 10px;
  }

  #workspaces button.urgent {
      color: #11111b;
      background: #a6e3a1;
      border-radius: 10px;
  }

  #workspaces button:hover {
      background: #11111b;
      color: #cdd6f4;
      border-radius: 10px;
  }

  #custom-language,
  #custom-logout,
  #custom-updates,
  #custom-caffeine,
  #custom-weather,
  #taskbar,
  #window,
  #clock,
  #battery,
  #pulseaudio,
  #network,
  #workspaces,
  #tray,
  #battery,
  #custom-launcher,
  #backlight {
      background: #1e1e2e;
      padding: 0px 10px;
      margin: 3px 0px;
      margin-top: 10px;
      border: 1px solid #181825;
      color: @white;
  }


  #backlight {
      border-radius: 10px 0px 0px 10px;
      border-right: 0px;
      margin-left: 0px;
  }

  #tray {
      border-radius: 10px;
      margin-right: 10px;
  }

  #workspaces {
      border-radius: 10px;
      margin-left: 10px;
      padding-right: 0px;
      padding-left: 5px;
  }

  #custom-language {
      border-left: 0px;
      border-right: 0px;
  }

  #custom-updates {
      border-radius: 10px;
      margin-right: 10px;
  }

  #window {
      border-radius: 10px;
      margin-left: 60px;
      margin-right: 60px;
  }

  #clock {
      margin-left: 0px;
      border-right: 0px;
  }

  #network {
      border-left: 0px;
      border-right: 0px;
  }

  #pulseaudio {
      border-left: 0px;
      border-right: 0px;
  }

  #pulseaudio.microphone {
      border-left: 0px;
      border-right: 0px;
  }

  #battery {
      margin-right: 0px;
      border-left: 0px;
  }

  #taskbar {
      border-radius: 10px;
      margin-right: 10px;
  }

  #custom-weather {
      border-radius: 0px 10px 10px 0px;
      border-right: 0px;
      margin-left: 0px;
  }

  #custom-logout {
      border-radius: 0px 10px 10px 0px;
      border-right: 0px;
      margin-left: 0px;
  }

  #custom-launcher {
      border-radius: 10px 10px 10px 10px;
      margin-right: 10px;
      margin-left: 10px;
      padding-right: 12.5px;
      padding-left: 12.5px;
  }
''
