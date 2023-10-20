{
  lib,
  pkgs,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "plymouth-theme-catppuccin";
  version = "2022-12-10";

  src = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "plymouth";
    rev = "d4105cf336599653783c34c4a2d6ca8c93f9281c";
    sha256 = "sha256-quBSH8hx3gD7y1JNWAKQdTk3CmO4t1kVo4cOGbeWlNE=";
  };

  installPhase = ''
    mkdir -p "$out/share/plymouth/themes/"
    cp -r "themes/"* "$out/share/plymouth/themes/"

    themes=("mocha" "macchiato" "frappe" "latte")
    for dir in "''${themes[@]}"; do
      cat "themes/catppuccin-''${dir}/catppuccin-''${dir}.plymouth" | sed "s@\/usr\/@''${out}\/@" > "''${out}/share/plymouth/themes/catppuccin-''${dir}/catppuccin-''${dir}.plymouth"
    done
  '';

  meta = with lib; {
    description = "Soothing pastel theme for Plymouth";
    homepage = "https://github.com/catppuccin/plymouth";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
