{pkgs, ...}: ''
  CHOOSE=$(${pkgs.gum}/bin/gum choose "cc by-nc-sa 4.0" "MIT" "GPLv3")

  if [ "$CHOOSE" = "cc by-nc-sa 4.0" ]; then
    LICENSE="https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode.txt"
  elif [ "$CHOOSE" = "MIT" ]; then
    LICENSE="https://opensource.org/licenses/MIT"
  elif [ "$CHOOSE" = "GPLv3" ]; then
    LICENSE="https://www.gnu.org/licenses/gpl-3.0.txt"
  else
    echo "You chose nothing"
    exit 1
  fi

  ${pkgs.curl}/bin/curl -o LICENSE $LICENSE
''
