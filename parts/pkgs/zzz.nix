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
    rev = "d30d03f389b98979fb5b5b7e87be0453dac741a8";
    hash = "sha256-dZVmn3MmoRZXo52oqsB/2fyszq+c6vuvTmjjWxI3QbI=";
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
