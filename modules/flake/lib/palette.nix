let
  /**
    every colour as `#rrggbb`, by name. also merged into the palette itself,
    so `palette.pink` and `palette.colors.pink` are the same

    # Example

    ```nix
    palette.colors.surface
    => "#0b0b11"
    ```
  */
  colors = {
    base = "#000000";
    surface = "#0b0b11";
    surfaceRaised = "#11111b";
    overlay = "#181825";
    border = "#313244";
    borderStrong = "#45475a";
    text = "#cdd6f4";
    textMuted = "#a6adc8";
    textSubtle = "#6c7086";
    textOnAccent = "#11111b";

    rosewater = "#f5e0dc";
    flamingo = "#f2cdcd";
    pink = "#f5c2e7";
    mauve = "#cba6f7";
    red = "#f38ba8";
    maroon = "#eba0ac";
    peach = "#fab387";
    yellow = "#f9e2af";
    green = "#a6e3a1";
    teal = "#94e2d5";
    sky = "#89dceb";
    sapphire = "#74c7ec";
    blue = "#89b4fa";
    lavender = "#b4befe";

    # one accent everywhere
    accent = "#f5c2e7";
  };

  /**
    every colour as space separated channels, for css that wraps them in
    `rgb()`

    # Example

    ```nix
    palette.rgb.accent
    => "245 194 231"
    ```
  */
  rgb = {
    base = "0 0 0";
    surface = "11 11 17";
    surfaceRaised = "17 17 27";
    overlay = "24 24 37";
    border = "49 50 68";
    borderStrong = "69 71 90";
    text = "205 214 244";
    textMuted = "166 173 200";
    textSubtle = "108 112 134";
    textOnAccent = "17 17 27";

    rosewater = "245 224 220";
    flamingo = "242 205 205";
    pink = "245 194 231";
    mauve = "203 166 247";
    red = "243 139 168";
    maroon = "235 160 172";
    peach = "250 179 135";
    yellow = "249 226 175";
    green = "166 227 161";
    teal = "148 226 213";
    sky = "137 220 235";
    sapphire = "116 199 236";
    blue = "137 180 250";
    lavender = "180 190 254";

    accent = "245 194 231";
  };

  /**
    every colour as `h s% l%`, for css that wraps it in `hsl()`

    # Example

    ```nix
    palette.hsl.accent
    => "316 72% 86%"
    ```
  */
  hsl = {
    base = "0 0% 0%";
    surface = "240 21% 5%";
    surfaceRaised = "240 23% 9%";
    overlay = "240 21% 12%";
    border = "237 16% 23%";
    borderStrong = "234 13% 31%";
    text = "226 64% 88%";
    textMuted = "228 24% 72%";
    textSubtle = "231 11% 47%";
    textOnAccent = "240 23% 9%";

    rosewater = "10 56% 91%";
    flamingo = "0 59% 88%";
    pink = "316 72% 86%";
    mauve = "267 84% 81%";
    red = "343 81% 75%";
    maroon = "350 65% 77%";
    peach = "23 92% 75%";
    yellow = "41 86% 83%";
    green = "115 54% 76%";
    teal = "170 57% 73%";
    sky = "189 71% 73%";
    sapphire = "199 76% 69%";
    blue = "217 92% 76%";
    lavender = "232 97% 85%";

    accent = "316 72% 86%";
  };
in
colors
// {
  inherit colors rgb hsl;
}
