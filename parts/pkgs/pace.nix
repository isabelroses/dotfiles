{
  lib,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
  ...
}: let
  version = "0.15.2";
in
  rustPlatform.buildRustPackage {
    pname = "pace";
    inherit version;

    src = fetchFromGitHub {
      owner = "pace-rs";
      repo = "pace";
      rev = "pace-rs-v${version}";
      hash = "sha256-gyyf4GGHIEdiAWvzKbaOApFikoh3RLWBCZUfJ0MjbIE=";
    };

    cargoSha256 = "sha256-D7jxju2R0S5wAsK7Gd8W32t/KKFaDjLHNZ2X/OEuPtk=";

    nativeBuildInputs = [installShellFiles];

    postInstall = ''
      installShellCompletion --cmd pace \
        --bash <($out/bin/pace setup completions bash) \
        --fish <($out/bin/pace setup completions fish) \
        --zsh <($out/bin/pace setup completions zsh)
    '';

    meta = with lib; {
      description = "Mindful Time Tracking: Simplify Your Focus and Boost Productivity Effortlessly.";
      homepage = "https://github.com/pace-rs/pace";
      license = licenses.agpl3;
      maintainers = with maintainers; [isabelroses];
      platforms = platforms.all;
    };
  }
