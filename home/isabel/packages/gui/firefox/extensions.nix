# should ideally be kept up to date with the latest version of the extensions
{ lib, pkgs, ... }:
let
  # define our buildFirefoxXpiAddon
  buildFirefoxXpiAddon = lib.makeOverridable (
    {
      src,
      pname,
      version,
      addonId,
      meta,
      ...
    }:
    pkgs.stdenv.mkDerivation {
      name = "${pname}-${version}";

      inherit meta src;

      preferLocalBuild = true;
      allowSubstitutes = true;

      passthru = {
        inherit addonId;
      };

      buildCommand = ''
        dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
        mkdir -p "$dst"
        install -v -m644 "$src" "$dst/${addonId}.xpi"
      '';
    }
  );

  # define our extensions
  extensions = {
    "stylus" = buildFirefoxXpiAddon {
      pname = "stylus";
      version = "1.5.46";
      addonId = "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}";

      src = pkgs.fetchurl {
        url = "https://addons.mozilla.org/firefox/downloads/file/4232144/styl_us-1.5.46.xpi";
        hash = "sha256-mnW/G93nJjpVAteACbXxkRfqCeYjevyFLnuk5StWU2Q=";
      };

      meta = {
        license = lib.licenses.gpl3;
        platforms = lib.platforms.all;
      };
    };

    "bitwarden" = buildFirefoxXpiAddon {
      pname = "bitwarden";
      version = "2024.6.2";
      addonId = "{446900e4-71c2-419f-a6a7-df9c091e268b}";

      src = pkgs.fetchurl {
        url = "https://addons.mozilla.org/firefox/downloads/file/4305759/bitwarden_password_manager-2024.6.2.xpi";
        hash = "sha256-wGTi1mAcuSHs0VTg07/VTXGvQ9oZR6pRZmh37wr9FDY=";
      };

      meta = {
        license = lib.licenses.gpl3;
        platforms = lib.platforms.all;
      };
    };

    "sponsorblock" = buildFirefoxXpiAddon {
      pname = "sponsorblock";
      version = "5.6.1";
      addonId = "sponsorBlocker@ajay.app";

      src = pkgs.fetchurl {
        url = "https://addons.mozilla.org/firefox/downloads/file/4299073/sponsorblock-5.6.1.xpi";
        hash = "sha256-TMrg68GqJtYcRGlW2kJb8W2v/VcE6iFnNeClfkgv6bo=";
      };

      meta = {
        license = lib.licenses.lgpl3;
        platforms = lib.platforms.all;
      };
    };

    "refined-github" = buildFirefoxXpiAddon {
      pname = "refined-github";
      version = "24.6.21";
      addonId = "{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}";

      src = pkgs.fetchurl {
        url = "https://addons.mozilla.org/firefox/downloads/file/4307292/refined_github-24.6.21.xpi";
        hash = "sha256-Djd0BAR6QwzDWejGRcAnR0bzkKi3Oj6q9GUUM7nCTjE=";
      };

      meta = {
        license = lib.licenses.mit;
        platforms = lib.platforms.all;
      };
    };
  };
in
{
  programs.firefox.profiles.default = {
    extensions = builtins.attrValues extensions;
  };
}
