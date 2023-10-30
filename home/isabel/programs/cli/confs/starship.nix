{
  osConfig,
  lib,
  ...
}: {
  programs.starship = {
    inherit (osConfig.modules.programs.cli) enable;
    catppuccin.enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    enableZshIntegration = true;

    settings = {
      add_newline = true;
      format = lib.concatStrings [
        "[╭╴](238)$os"
        "$all[╰─󰁔](237)$character"
      ];
      character = {
        success_symbol = "";
        error_symbol = "";
      };
      container = {
        symbol = " 󰏖";
        format = "[$symbol ](yellow dimmed)";
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
        home_symbol = "󰋞 ~";
        read_only_style = "197";
        read_only = "  ";
        format = "at [$path]($style)[$read_only]($read_only_style) ";
      };
      directory.substitutions = {
        "documents" = " ";
        "downloads" = " ";
        "media/music" = " ";
        "media/pictures" = " ";
        "media/videos" = " ";
        "dev" = "󱌢 ";
        "skl" = "󰑴 ";
        ".config" = " ";
      };
      os = {
        disabled = true;
        style = "bold white";
        format = "[$symbol]($style)";
      };
      # If it is commented out it does not exist yet
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
      python = {
        symbol = "";
        format = "[$symbol ](yellow)";
      };
      nodejs = {
        symbol = " ";
        format = "[$symbol ](yellow)";
      };
      lua = {
        symbol = "󰢱";
        format = "[$symbol ](blue)";
      };
      rust = {
        symbol = "";
        format = "[$symbol ](red)";
      };
      docker_context = {
        symbol = "";
        format = "[$symbol ](blue)";
      };
      java = {
        symbol = "";
        format = "[$symbol ](red)";
      };
      c = {
        symbol = "";
        format = "[$symbol ](blue)";
      };
      golang = {
        symbol = "";
        format = "[$symbol ](blue)";
      };
      battery = {
        disabled = true;
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
