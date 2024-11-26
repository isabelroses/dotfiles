{
  programs.git.aliases = {
    index = "status -s";
    graph = "log --oneline --graph";
    ahead = "!git log --oneline @{u}..HEAD | grep -cE '.*'";

    changelog = "-c pager.show=false show --format=' - %C(yellow)%h%C(reset) %<(80,trunc)%s' -q @@{1}..@@{0}";
    amend = "commit --amend";

    fpush = "push --force-with-lease";

    # stash
    spush = "stash push -a";
    spop = "stash pop -q";
  };
}
