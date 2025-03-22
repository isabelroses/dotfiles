{
  lib,
  config,
  osConfig,
  ...
}:
let
  inherit (lib.modules) mkIf;

  cfg = config.garden.programs.rofi;
  inherit (config.garden.programs) defaults;
in
{
  programs.rofi = mkIf cfg.enable {
    enable = true;
    inherit (cfg) package;

    extraConfig = {
      modi = "drun";
      icon-theme = "Papirus-Dark";
      show-icons = true;
      inherit (defaults) terminal;
      location = 0;
      disable-history = false;
      hide-scrollbar = true;
      sidebar-mode = true;
      font =
        let
          fn = osConfig.garden.style.font;
        in
        "${fn.name} ${toString fn.size}";
      display-drun = "Apps";
      drun-display-format = "{name}";
    };

    theme =
      let
        inherit (config.lib.formats.rasi) mkLiteral;
      in
      {
        "*" = {
          bg-col = mkLiteral "#1e1e2e";
          bg-col-light = mkLiteral "#1e1e2e";
          border-col = mkLiteral "#313244";
          selected-col = mkLiteral "#1e1e2e";
          sapphire = mkLiteral "#74c7ec";
          fg-col = mkLiteral "#cdd6f4";
          fg-col2 = mkLiteral "@sapphire";
          grey = mkLiteral "#a6adc8";

          width = mkLiteral "450px";
        };

        "element-text, element-icon , mode-switcher" = {
          background-color = mkLiteral "inherit";
          text-color = mkLiteral "inherit";
        };

        "window" = {
          height = mkLiteral "500px";
          border = mkLiteral "3px";
          border-radius = mkLiteral "15px";
          border-color = mkLiteral "@border-col";
          background-color = mkLiteral "@bg-col";
        };

        "mainbox" = {
          background-color = mkLiteral "@bg-col";
        };

        inputbar = {
          children = mkLiteral "[prompt,entry]";
          background-color = mkLiteral "@bg-col";
          border-radius = mkLiteral "15px";
          padding = mkLiteral "2px";
        };

        prompt = {
          background-color = mkLiteral "@sapphire";
          padding = mkLiteral "6px";
          text-color = mkLiteral "@bg-col";
          border-radius = mkLiteral "15px";
          margin = mkLiteral "20px 0px 0px 20px";
        };

        textbox-prompt-colon = {
          expand = false;
          str = ":";
        };

        entry = {
          padding = mkLiteral "6px";
          margin = mkLiteral "20px 0px 0px 10px";
          text-color = mkLiteral "@fg-col";
          background-color = mkLiteral "@bg-col";
        };

        listview = {
          border = mkLiteral "0px 0px 0px";
          padding = mkLiteral "6px 0px 0px";
          margin = mkLiteral "10px 0px 0px 20px";
          columns = 1;
          lines = 10;
          background-color = mkLiteral "@bg-col";
        };

        element = {
          padding = mkLiteral "5px";
          background-color = mkLiteral "@bg-col";
          text-color = mkLiteral "@fg-col";
        };

        element-icon = {
          size = mkLiteral "25px";
        };

        "element selected" = {
          background-color = mkLiteral "@selected-col";
          text-color = mkLiteral "@fg-col2";
        };

        mode-switcher = {
          spacing = 0;
        };

        button = {
          padding = mkLiteral "10px";
          background-color = mkLiteral "@bg-col-light";
          text-color = mkLiteral "@grey";
          vertical-align = mkLiteral "0.5";
          horizontal-align = mkLiteral "0.5";
        };

        "button selected" = {
          background-color = mkLiteral "@bg-col";
          text-color = mkLiteral "@sapphire";
        };
      };
  };
}
