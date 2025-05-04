{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.strings) concatStrings;
  configFormat = pkgs.formats.toml { };

  # TODO: come back and change this a bit
  ss = symbol: style: {
    inherit symbol;
    format = "[$symbol ](${style})";
  };
  ssv = symbol: style: {
    inherit symbol;
    format = "via [$symbol](${style})";
  };

  cfg = config.garden.wrappers.starship;
in
{
  garden.wrappers = {
    fish = {
      env.STARSHIP_CONFIG = toString (configFormat.generate "starship-config" cfg.settings);
    };

    starship = {
      enable = true;
      package = pkgs.starship;

      settings = {
        add_newline = true;
        format = concatStrings [
          "[╭╴](238)$os"
          "$all[╰─󰁔](237)$character"
        ];

        character = {
          success_symbol = "";
          error_symbol = "";
        };

        username = {
          style_user = "white";
          style_root = "black";
          format = "[$user]($style) ";
          show_always = true;
        };

        directory = {
          truncation_length = 3;
          truncation_symbol = "…/";
          home_symbol = "󰋞 ";
          read_only_style = "197";
          read_only = "  ";
          format = "at [$path]($style)[$read_only]($read_only_style) ";

          substitutions = {
            "󰋞 /Documents" = "󰈙 ";
            "󰋞 /documents" = "󰈙 ";

            "󰋞 /Downloads" = " ";
            "󰋞 /downloads" = " ";

            "󰋞 /media/music" = " ";
            "󰋞 /media/pictures" = " ";
            "󰋞 /media/videos" = " ";
            "󰋞 /Music" = " ";
            "󰋞 /Pictures" = " ";
            "󰋞 /Videos" = " ";

            "󰋞 /dev" = "󱌢 ";
            "󰋞 /Dev" = "󱌢 ";

            "󰋞 /skl" = "󰑴 ";
            "󰋞 /.config" = " ";
          };
        };

        os = {
          style = "bold white";
          format = "[$symbol]($style)";

          symbols = {
            Arch = "";
            Artix = "";
            Debian = "";
            # Kali = "󰠥";
            EndeavourOS = "";
            Fedora = "";
            NixOS = "";
            openSUSE = "";
            SUSE = "";
            Ubuntu = "";
            Raspbian = "";
            #elementary = "";
            #Coreos = "";
            Gentoo = "";
            #mageia = ""
            CentOS = "";
            #sabayon = "";
            #slackware = "";
            Mint = "";
            Alpine = "";
            #aosc = "";
            #devuan = "";
            Manjaro = "";
            #rhel = "";
            Macos = "󰀵";
            Linux = "";
            Windows = "";
          };
        };

        container = ss " 󰏖" "yellow dimmed";
        python = ss "" "yellow";
        nodejs = ss " " "yellow";
        lua = ss "󰢱 " "blue";
        rust = ss "" "red";
        java = ss " " "red";
        c = ss " " "blue";
        golang = ss "" "blue";
        docker_context = ss " " "blue";

        nix_shell = ssv " " "blue";

        git_branch = {
          symbol = "󰊢 ";
          format = "on [$symbol$branch]($style) ";
          truncation_length = 4;
          truncation_symbol = "…/";
          style = "bold green";
        };
        git_status = {
          format = "[\\($all_status$ahead_behind\\)]($style) ";
          style = "bold green";
          conflicted = "🏳";
          up_to_date = " ";
          untracked = " ";
          ahead = "⇡\${count}";
          diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
          behind = "⇣\${count}";
          stashed = "󰏗 ";
          modified = " ";
          staged = "[++\\($count\\)](green)";
          renamed = "󰖷 ";
          deleted = " ";
        };

        battery.disabled = true;
      };
    };
  };
}
