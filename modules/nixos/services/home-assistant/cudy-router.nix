{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  beautifulsoup4,
  python-dateutil,
}:
buildHomeAssistantComponent rec {
  owner = "usersaynoso";
  domain = "cudy_router";
  version = "1.3.42";

  src = fetchFromGitHub {
    owner = "usersaynoso";
    repo = "ha-cudy-router";
    tag = "v${version}";
    hash = "sha256-PI0nwmWjKJe3OPdW6TS/ON/NelGiJMhUqHMZx9TmP7U=";
  };

  dependencies = [
    beautifulsoup4
    python-dateutil
  ];

  # the manifest pins dateutil exactly, whatever nixpkgs ships is close enough
  ignoreVersionRequirement = [ "python-dateutil" ];

  meta = {
    description = "Home Assistant integration for Cudy routers";
    homepage = "https://github.com/usersaynoso/ha-cudy-router";
    changelog = "https://github.com/usersaynoso/ha-cudy-router/releases/tag/v${version}";
    license = lib.licenses.gpl3Only;
  };
}
