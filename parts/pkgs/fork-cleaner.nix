{
  lib,
  buildGoModule,
  fetchFromGitHub,
}: let
  version = "2.3.1";
in
  buildGoModule {
    name = "fork-cleaner";
    inherit version;

    src = fetchFromGitHub {
      owner = "caarlos0";
      repo = "fork-cleaner";
      rev = "v${version}";
      sha256 = "sha256-JNmpcDwmxR+s4regOWz8FAJllBNRfOCmVwkDs7tlChA=";
    };

    vendorHash = "sha256-QuIaXXkch5PCpX8P755X8j7MeNnbewWo7NB+Vue1/Pk=";

    ldflags = [
      "-s"
      "-w"
      "-X main.Version=${version}"
    ];

    meta = {
      description = "Quickly clean up unused forks on your github account";
      homepage = "https://github.com/caarlos0/fork-cleaner";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [isabelroses];
      platforms = lib.platforms.all;
    };
  }
