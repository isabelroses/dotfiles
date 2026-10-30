{
  lib,
  python3Packages,
  gallery-dl,
  yt-dlp,
  ffmpeg,
}:
python3Packages.buildPythonApplication {
  pname = "gup";
  version = "0";
  pyproject = false;

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./gup
      ./tests
    ];
  };

  # gallery-dl brings the yt-dlp its ytdl extractor imports
  dependencies = [
    (python3Packages.toPythonModule (gallery-dl.override { inherit yt-dlp; }))
    python3Packages.httpx
  ];

  # yt-dlp merges separate video and audio streams with ffmpeg
  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [ ffmpeg ])
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 gup "$out/bin/gup"

    runHook postInstall
  '';

  doCheck = true;

  checkPhase = ''
    runHook preCheck

    python -m unittest discover -s tests -v

    runHook postCheck
  '';

  meta = {
    description = "Download media with gallery-dl and yt-dlp and upload it to Immich";
    license = lib.licenses.eupl12;
    mainProgram = "gup";
    maintainers = with lib.maintainers; [ isabelroses ];
  };
}
