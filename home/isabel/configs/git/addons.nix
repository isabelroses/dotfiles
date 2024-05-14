{ pkgs, ... }:
{
  home.packages = with pkgs; [
    gist # manage github gists
    # act # local github actions - littrally does not work
    gitflow # Extend git with the Gitflow branching model
  ];
}
