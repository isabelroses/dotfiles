{
  lib,
  python3Packages,
  gallery-dl,
  yt-dlp,
  ffmpeg,
  mkvtoolnix-cli,
}:
python3Packages.buildPythonApplication {
  pname = "gup";
  version = "0";
  pyproject = true;

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./pyproject.toml
      ./src
      ./tests
    ];
  };

  build-system = [ python3Packages.uv-build ];

  # gallery-dl brings the yt-dlp its ytdl extractor imports
  dependencies = [
    (python3Packages.toPythonModule (
      (gallery-dl.override { inherit yt-dlp; }).overrideAttrs (_: {
        patches = [
          ./fix-twt.patch
        ];
      })
    ))
    python3Packages.httpx
  ];

  # yt-dlp merges separate video and audio streams with ffmpeg, and
  # gallery-dl turns pixiv's ugoira zips into webm with ffmpeg and mkvmerge
  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [
      ffmpeg
      mkvtoolnix-cli
    ])
  ];

  nativeCheckInputs = [ python3Packages.unittestCheckHook ];
  unittestFlags = [
    "-s"
    "tests"
    "-v"
  ];

  pythonImportsCheck = [ "gup.cli" ];

  meta = {
    description = "Download media with gallery-dl and yt-dlp and upload it to Immich";
    license = lib.licenses.eupl12;
    mainProgram = "gup";
    maintainers = with lib.maintainers; [ isabelroses ];
  };
}
