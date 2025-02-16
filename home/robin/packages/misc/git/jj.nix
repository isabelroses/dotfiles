{
  lib,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  cfg = config.garden.programs;
in
{
  config = mkIf (cfg.cli.enable && cfg.git.enable) {
    programs.jujutsu = {
      enable = true;
      settings = {
        user = {
          name = config.programs.git.userName;
          email = config.programs.git.userEmail;
        };

        aliases = {
          name = [
            "bookmark"
            "set"
            "-r"
            "git_head()"
          ];
          update = [
            "bookmark"
            "move"
            "--to"
            "git_head()"
          ];
        };

        ui = {
          default-command = "status";
          diff-editor = "nvim-hunk";
          merge-editor = "nvim-hunk";
        };

        templates = {
          log = "custom_log_compact";
        };

        template-aliases = {
          # custom components
          "format_short_signature(signature)" = "signature.email().local()";
          "format_timestamp(timestamp)" = "timestamp.local().format('%Y%m%d %I:%M %P')";
          "format_custom_commit_header(commit)" = ''
            separate(" ",
              format_short_change_id_with_hidden_and_divergent_info(commit),
              format_short_commit_id(commit.commit_id()),
              commit.bookmarks(),
              commit.tags(),
              commit.working_copies(),
              if(commit.git_head(), label("git_head", "git_head()")),
              label("separator", "|"),
              if(commit.conflict(), label("conflict", "conflict")),
              format_short_signature(commit.author()),
              if(config("ui.show-cryptographic-signatures").as_boolean(),
                format_short_cryptographic_signature(commit.signature())),
            )
          '';

          # custom templates
          "custom_log_compact" = ''
            if(root,
              format_root_commit(self),
              label(if(current_working_copy, "working_copy"),
                concat(
                  format_custom_commit_header(self) ++ "\n",
                  separate(" ",
                    if(empty, label("empty", "(empty)")),
                    if(description,
                      description.first_line(),
                      label(if(empty, "empty"), description_placeholder),
                    ),
                  ) ++ "\n",
                ),
              )
            )
          '';
        };

        merge-tools.nvim = {
          edit-args = [
            "-d"
            "$left"
            "$right"
          ];
        };
        merge-tools.nvim-hunk = {
          program = "nvim";
          edit-args = [
            "-c"
            "DiffEditor $left $right $output"
          ];
        };
      };
    };
  };
}
