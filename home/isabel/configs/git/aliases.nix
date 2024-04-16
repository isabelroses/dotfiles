{
  programs.git.aliases = {
    st = "status";
    br = "branch";
    c = "commit -m";
    ca = "commit -am";
    co = "checkout";
    d = "diff";
    df = "!git hist | peco | awk '{print $2}' | xargs -I {} git diff {}^ {}";
    fuck = "commit --amend -m";
    graph = "log --all --decorate --graph";
    ps = "!git push origin $(git rev-parse --abbrev-ref HEAD)";
    pl = "!git pull origin $(git rev-parse --abbrev-ref HEAD)";
    af = "!git add $(git ls-files -m -o --exclude-standard | fzf -m)";
    hist = ''
      log --pretty=format:"%Cgreen%h %Creset%cd %Cblue[%cn] %Creset%s%C(yellow)%d%C(reset)" --graph --date=relative --decorate --all
    '';
    llog = ''
      log --graph --name-status --pretty=format:"%C(red)%h %C(reset)(%cd) %C(green)%an %Creset%s %C(yellow)%d%Creset" --date=relative
    '';
  };
}
