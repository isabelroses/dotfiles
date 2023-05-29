{pkgs, ...}: {
  home.packages = with pkgs; [swaylock-effects];
  programs.swaylock = {
    settings = {
      # Options
      ignore-empty-password = true;
      show-failed-attempts = true;
      clock = true;

      # Style
      indicator-radius=120;
      indicator-thickness=20;
      line-uses-ring = true;
      font="RobotoMono Nerd Font Regular";
      font-size=32;

      # Background
      # @Crust
      color="11111bff";

      # Separator
      # @Surface0
      separator-color="3132441c";

      # Typing Password
      # @Blue
      key-hl-color="89b4fa80";
      # @Lavender
      bs-hl-color="b4befe80";

      # Color Caps Lock Text
      # @Sapphire
      text-caps-lock-color="74c7ecff";

      # Default Password
      # @Blue
      text-color="89b4fa3eff";
      # @Base
      inside-color="1e1e2e1c";
      # @Blue
      ring-color="89b4fa3e";
      # @Crust
      line-color="11111b00";

      # Clear Password
      # @Green
      text-clear-color="a6e3a1ff";
      # @Base
      inside-clear-color="1e1e2e1c";
      # @Green
      ring-clear-color="a6e3a13e";
      # @Crust
      line-clear-color="11111b00";

      # Verification Password
      # @Yellow
      text-ver-color="f9e2afff";
      # @Base
      inside-ver-color="1e1e2e1c";
      # @Yellow
      ring-ver-color="f9e2af3e";
      # @Crust
      line-ver-color="11111b00";

      # Wrong Password
      # @Red
      text-wrong-color="f38ba8ff";
      # @Base
      inside-wrong-color="1e1e2e1c";
      # @Red
      ring-wrong-color="f38ba855";
      # @Crust
      line-wrong-color="11111b00";
    };
  };
}