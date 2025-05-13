{ config, ... }:
{
  programs.jujutsu = {
    inherit (config.garden.profiles.workstation) enable;

    settings = {
      user = {
        name = config.programs.git.userName;
        email = config.programs.git.userEmail;
      };

      aliases = {
        # create named bookmark at HEAD
        name = [
          "bookmark"
          "create"
          "-r"
          "head"
        ];
        # update bookmark <arg> to point to HEAD
        update = [
          "bookmark"
          "move"
          "--to"
          "head"
        ];
        # pull up the nearest bookmarks to the last described commit
        tug = [
          "bookmark"
          "move"
          "--from"
          "curbranch"
          "--to"
          "latest"
        ];

        # push the nearest bookmark
        push = [
          "git"
          "push"
          "-r"
          "curbranch"
        ];

        # pull incoming changes onto working branch
        pull = [
          "rebase"
          "-d"
          "trunk()"
          "--skip-emptied"
        ];
      };

      "revset-aliases" = {
        "head" = "git_head()";
        "latest" = "latest(curbranch::@ ~ empty())";

        "bases" = "dev";
        "downstream(x,y)" = "(x::y) & y";
        "branches" = "downstream(trunk(), bookmarks() ~ bases)";
        "heads" = "heads(trunk()::)";
        "leafs" = "branches | heads";
        "curbranch" = "latest(branches::@- & branches)";
        "nextbranch" = "roots(@:: & branchesandheads)";
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

      colors = {
        "working_copy commit_id" = "#6E8585";
        "working_copy empty" = "#3F4D52";
        "working_copy empty description placeholder" = "#3F4D52";
      };
    };
  };
}
