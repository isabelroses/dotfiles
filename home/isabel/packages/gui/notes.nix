{
  pkgs,
  config,
  ...
}:
let
  inherit (builtins) attrValues;

  inherit (config.garden.programs) defaults;
in
{
  config.garden.programs = {
    obsidian.runtimeInputs = attrValues {
      inherit (pkgs)
        # for the pandoc plugin
        pandoc

        # for the obsidian-git plugin
        gitMinimal
        git-lfs
        ;
    };

    zk.settings = {
      note = {
        # The default title used for new note, if no `--title` flag is provided.
        default-title = "untitled";

        # The charset used for random IDs. You can use:
        #   * letters: only letters from a to z.
        #   * numbers: 0 to 9
        #   * alphanum: letters + numbers
        #   * hex: hexadecimal, from a to f and 0 to 9
        #   * custom string: will use any character from the provided value
        id-charset = "hex";

        # Length of the generated IDs.
        id-length = 6;
      };

      tool = {
        inherit (defaults) editor;
        pager = "bat";

        # Command used to preview a note during interactive fzf mode.
        # Set it to an empty string "" to disable preview.
        fzf-preview = "bat -p --color always {-1}";
      };

      alias = {
        list = "zk list --quiet -f oneline $@";
        ls = "zk list $@";
        wc = "zk list --sort word-count $@";

        search = "zk list -i $@";

        # Edit the last modified note.
        editlast = "zk edit --limit 1 --sort modified- $@";

        # Edit the notes selected interactively among the notes created the last two weeks.
        # This alias doesn't take any argument, so we don't use $@.
        recent = "zk edit --sort created- --created-after 'last two weeks' --interactive";

        # Print paths separated with colons for the notes found with the given
        # arguments. This can be useful to expand a complex search query into a flag
        # taking only paths. For example:
        #   zk list --link-to "`zk path -m potato`"
        path = "zk list --quiet --format {{path}} --delimiter , $@";

        # Returns the Git history for the notes found with the given arguments.
        # Note the use of a pipe and the location of $@.
        hist = "zk list --format path --delimiter0 --quiet $@ | xargs -t -0 git log --patch --";

        tags = "zk tag list $@";
      };
    };
  };
}
