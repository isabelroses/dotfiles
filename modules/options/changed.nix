{lib, ...}: let
  inherit (lib) mkRenamedOptionModule mkRemovedOptionModule;
in {
  imports = [
    # Renamed modules
    (mkRenamedOptionModule ["modules" "usrEnv"] ["modules" "environment"])

    (mkRenamedOptionModule ["modules" "system" "flakePath"] ["modules" "environment" "flakePath"])

    (mkRenamedOptionModule ["modules" "programs" "git"] ["modules" "programs" "agnostic" "git"])
    (mkRenamedOptionModule ["modules" "programs" "editors"] ["modules" "programs" "agnostic" "editors"])

    (mkRenamedOptionModule ["modules" "programs" "bars"] ["modules" "programs" "gui" "bars"])
    (mkRenamedOptionModule ["modules" "programs" "browser"] ["modules" "programs" "gui" "browsers"])
    (mkRenamedOptionModule ["modules" "programs" "fileManagers"] ["modules" "programs" "gui" "fileManagers"])
    (mkRenamedOptionModule ["modules" "programs" "launchers"] ["modules" "programs" "gui" "launchers"])
    (mkRenamedOptionModule ["modules" "programs" "zathura"] ["modules" "programs" "gui" "zathura"])
    (mkRenamedOptionModule ["modules" "programs" "terminals"] ["modules" "programs" "gui" "terminals"])

    (mkRenamedOptionModule ["modules" "programs" "defaults" "loginManager"] ["modules" "environment" "loginManager"])

    (mkRenamedOptionModule ["modules" "services" "forgejo"] ["modules" "services" "dev" "forgejo"])
    (mkRenamedOptionModule ["modules" "services" "vscode-server"] ["modules" "services" "dev" "vscode-server"])
    (mkRenamedOptionModule ["modules" "services" "plausible"] ["modules" "services" "dev" "plausible"])
    (mkRenamedOptionModule ["modules" "services" "wakapi"] ["modules" "services" "dev" "wakapi"])

    (mkRenamedOptionModule ["modules" "services" "searxng"] ["modules" "services" "media" "searxng"])
    (mkRenamedOptionModule ["modules" "services" "matrix"] ["modules" "services" "media" "matrix"])
    (mkRenamedOptionModule ["modules" "services" "jellyfin"] ["modules" "services" "media" "jellyfin"])
    (mkRenamedOptionModule ["modules" "services" "photoprism"] ["modules" "services" "media" "photoprism"])
    (mkRenamedOptionModule ["modules" "services" "nextcloud"] ["modules" "services" "media" "nextcloud"])

    (mkRenamedOptionModule ["modules" "services" "nginx"] ["modules" "services" "networking" "nginx"])
    (mkRenamedOptionModule ["modules" "services" "headscale"] ["modules" "services" "networking" "headscale"])
    (mkRenamedOptionModule ["modules" "services" "cloudflared"] ["modules" "services" "networking" "cloudflared"])

    # Removed modules
    (mkRemovedOptionModule ["modules" "services" "smb"] "not used anymore")
    (mkRemovedOptionModule ["modules" "services" "miniflux"] "not used anymore")
    (mkRemovedOptionModule ["modules" "services" "dns"] "not used anymore")
    (mkRemovedOptionModule ["modules" "services" "cyberchef"] "pkg dropped")
  ];
}
