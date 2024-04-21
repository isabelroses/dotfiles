{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule {
  pname = "zzz";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "isabelroses";
    repo = "zzz";
    rev = "933992381b09905e17a370758daf53458fe40434";
    hash = "sha256-QXCrh3h6E8EUX47yLTv/73SEnjXtv9ylrtH9Ow0jssQ=";
  };

  vendorHash = "sha256-ePHkrsc9NJO8c3J1eDkFeSLvVs5flSeiTmXqkfF261s=";

  meta = {
    description = "Code snippets in your terminal 🛌";
    mainProgram = "zzz";
    homepage = "https://github.com/isabelroses/zzz";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [isabelroses];
  };
}
