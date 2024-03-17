{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) getExe;
in ''
  CHOOSE=$(${getExe pkgs.gum} choose "cc by-nc-sa 4.0" "MIT" "GPLv3")

  if [ "$CHOOSE" = "cc by-nc-sa 4.0" ]; then
    LICENSE="https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode.txt"
  elif [ "$CHOOSE" = "MIT" ]; then
    LICENSE="https://gist.githubusercontent.com/isabelroses/fa6f71651be564ada535bb56dec1e13b/raw/c766f746e94771d92bea73db881a567215b5fe77/MIT%2520License"
  elif [ "$CHOOSE" = "GPLv3" ]; then
    LICENSE="https://www.gnu.org/licenses/gpl-3.0.txt"
  else
    echo "You chose nothing"
    exit 1
  fi

  ${getExe pkgs.curl} -o LICENSE $LICENSE
''
