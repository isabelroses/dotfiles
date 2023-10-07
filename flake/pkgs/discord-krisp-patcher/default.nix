{pkgs, ...}:
pkgs.stdenv.mkDerivation {
  name = "discord-krisp-patcher";
  src = ./.;

  installPhase = ''
    mkdir -p $out/bin

    substitute $src/discord-krisp-patcher.sh $out/bin/discord-krisp-patcher \
      --replace "#!/usr/bin/env nix-shell" "#!${pkgs.bash}/bin/bash" \
      --replace 'rizin_cmd="rizin"' "rizin_cmd=${pkgs.rizin}/bin/rizin" \
      --replace 'rz_find_cmd="rz-find"' "rz_find_cmd=${pkgs.rizin}/bin/rz-find"

    chmod +x $out/bin/discord-krisp-patcher
  '';
}
