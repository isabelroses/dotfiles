{ config, ... }:
let
  # TODO: come back and change this a bit
  ss = symbol: style: {
    inherit symbol;
    format = "[$symbol ](${style})";
  };
in
{
  programs.starship = {
    inherit (config.garden.profiles.workstation) enable;

    settings = {
      add_newline = true;
      format = "$all$character";

      character = {
        success_symbol = "[󰧟](green)";
        error_symbol = "[󰧟](red)";
        vimcmd_symbol = "[󰝦](bright-black)";
        vimcmd_replace_one_symbol = "[r](bright-black)";
        vimcmd_replace_symbol = "[R](bright-black)";
        vimcmd_visual_symbol = "[󰝦](purple)";
      };

      username = {
        style_user = "bright-white";
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
        style = "cyan";
        format = "[$path]($style)[$read_only]($read_only_style) ";
        truncate_to_repo = true;
        before_repo_root_style = "";
        repo_root_style = "cyan";
        repo_root_format = "[\\[$repo_root\\]]($repo_root_style) [$path]($style)[$read_only]($read_only_style) ";

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

      nix_shell = ss "@devshell" "blue";

      git_branch = {
        symbol = "󰘬 ";
        format = "[$symbol $branch]($style) ";
        truncation_length = 4;
        truncation_symbol = "…/";
        style = "purple";
      };
      git_status = {
        format = "[$all_status$ahead_behind]($style) ";
        style = "bold green";
        conflicted = "=";
        up_to_date = "󰄬 ";
        untracked = "? ";
        ahead = "⇡\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        behind = "⇣\${count}";
        stashed = "󰏗 ";
        modified = "M ";
        staged = "[++\\($count\\)](green)";
        renamed = " ";
        deleted = " ";
        disabled = true;
      };

      battery.disabled = true;
      cmd_duration.disabled = true;
    };
  };
}
