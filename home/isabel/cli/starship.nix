{ lib, config, ... }:
let
  inherit (lib) concatStrings;

  fmt = symbol: {
    inherit symbol;
    format = "[$symbol]($style)";
  };
in
{
  programs.starship = {
    inherit (config.garden.profiles.workstation) enable;

    settings = {
      add_newline = true;
      format = concatStrings [
        "[╭╴](238)$os"
        "$all[╰─󰁔](237)$character"
      ];

      character.disabled = true;
      battery.disabled = true;

      container = fmt "󰏖";
      python = fmt "";
      nodejs = fmt " ";
      lua = fmt "󰢱 ";
      rust = fmt "";
      java = fmt " ";
      c = fmt " ";
      golang = fmt "";
      docker_context = fmt " ";
      nix_shell = fmt " ";

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
    };
  };
}
