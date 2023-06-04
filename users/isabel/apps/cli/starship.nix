{
  config,
  pkgs,
  lib,
  ...
}: {
  home.packages = [ pkgs.starship ];
  programs.starship = {
    enable = true;
    catppuccin.enable = true;
    settings = {
      add_newline = true;

      format = """\
        [╭╴](238)$os \
        $all[╰─󰁔](238)$character""";

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

      os = {
        format = "[$symbol]($style)";
        style = "bold white";
        disabled = false;
      };

      os.symbols = {
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

      directory = {
        truncation_length = 3;
        truncation_symbol = "…/";
        home_symbol = "󰋞 ~";
        read_only_style = "197";
        read_only = "  ";
        format = "at [$path]($style)[$read_only]($read_only_style) ";
      };

      git_branch = {
        symbol = "󰊢 ";
        format = "on [$symbol$branch]($style) ";
        truncation_length = 4;
        truncation_symbol = "…/";
        style = "bold green";
      };

      git_status = {
        format = "[\($all_status$ahead_behind\)]($style) ";
        style = "bold green";
        conflicted = "🏳";
        up_to_date = " ";
        untracked = " ";
        ahead = "⇡${count}";
        diverged = "⇕⇡${ahead_count}⇣${behind_count}";
        behind = "⇣${count}";
        stashed = "󰏗 ";
        modified = " ";
        staged = "[++\($count\)](green)";
        renamed = "󰖷 ";
        deleted = " ";
      };

      terraform = {
        format = "via [ terraform $version]($style) 󰑃 [$workspace]($style) ";
      };

      vagrant = {
        format = "via [ vagrant $version]($style) ";
      };

      docker_context = {
        format = "via [ $context](bold blue) ";
      };

      helm = {
        format = "via [ $version](bold purple) ";
      };

      python = {
        symbol = "󰌠 ";
        python_binary = "python3";
      };

      nodejs = {
        format = "via [󰎙 $version](bold green) ";
        disabled = true;
      };

      ruby = {
        format = "via [ $version]($style) ";
      };

      battery = {
        disabled = true;
      };

      nix_shell = {
        disabled = false;
        format = "[](fg:white)[ ](bg:white fg:black)[](fg:white) ";
      };
    };
  };
}
