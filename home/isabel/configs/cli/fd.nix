{
  lib,
  osConfig,
  ...
}: {
  programs.fd = lib.mkIf (lib.isModernShell osConfig) {
    enable = true;

    hidden = true;
    ignores = [
      ".git/"
      "*.bak"
    ];
  };
}
