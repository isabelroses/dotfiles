{
  lib,
  config,
  ...
}:
{
  programs.yazi = lib.mkIf config.garden.profiles.workstation.enable {
    enable = true;

    settings = {
      mgr = {
        sorty_by = "extension";
        show_hidden = true;
        show_symlink = true;
        sort_sensitive = true;
      };
      opener = {
        edit = [
          {
            run = ''$EDITOR "$@"'';
            block = true;
            for = "unix";
          }
        ];
        open = [
          {
            run = ''xdg-open "$@"'';
            desc = "Open";
            for = "linux";
          }
          {
            run = ''open "$@"'';
            desc = "Open";
            for = "macos";
          }
        ];
        reveal = [
          {
            run = ''open -R "$1"'';
            desc = "Reveal";
            for = "macos";
          }
          {
            run = ''exiftool "$1"; echo "Press enter to exit"; read'';
            block = true;
            desc = "Show EXIF";
            for = "unix";
          }
        ];
        extract = [
          {
            run = ''unar "$1"'';
            desc = "Extract here";
            for = "unix";
          }
        ];
        play = [
          {
            run = ''mpv "$@"'';
            orphan = true;
            for = "unix";
          }
          {
            run = ''mediainfo "$1"; echo "Press enter to exit"; read'';
            block = true;
            desc = "Show media info";
            for = "unix";
          }
        ];
      };
      open = {
        rules = [
          {
            name = "*/";
            use = [
              "edit"
              "open"
              "reveal"
            ];
          }

          {
            mime = "text/*";
            use = [
              "edit"
              "reveal"
            ];
          }
          {
            mime = "image/*";
            use = [
              "open"
              "reveal"
            ];
          }
          {
            mime = "video/*";
            use = [
              "play"
              "reveal"
            ];
          }
          {
            mime = "audio/*";
            use = [
              "play"
              "reveal"
            ];
          }
          {
            mime = "inode/x-empty";
            use = [
              "edit"
              "reveal"
            ];
          }

          {
            mime = "application/json";
            use = [
              "edit"
              "reveal"
            ];
          }
          {
            mime = "*/javascript";
            use = [
              "edit"
              "reveal"
            ];
          }

          {
            mime = "application/zip";
            use = [
              "extract"
              "reveal"
            ];
          }
          {
            mime = "application/gzip";
            use = [
              "extract"
              "reveal"
            ];
          }
          {
            mime = "application/x-tar";
            use = [
              "extract"
              "reveal"
            ];
          }
          {
            mime = "application/x-bzip";
            use = [
              "extract"
              "reveal"
            ];
          }
          {
            mime = "application/x-bzip2";
            use = [
              "extract"
              "reveal"
            ];
          }
          {
            mime = "application/x-7z-compressed";
            use = [
              "extract"
              "reveal"
            ];
          }
          {
            mime = "application/x-rar";
            use = [
              "extract"
              "reveal"
            ];
          }

          {
            mime = "*";
            use = [
              "open"
              "reveal"
            ];
          }
        ];
      };
    };

    theme = {
      manager = {
        tab_width = 1;
        border_symbol = " ";
        folder_offset = [
          1
          0
          1
          0
        ];
        preview_offset = [
          1
          1
          1
          1
        ];
      };
      status = {
        separator_open = "";
        separator_close = "";
      };
    };
  };
}
