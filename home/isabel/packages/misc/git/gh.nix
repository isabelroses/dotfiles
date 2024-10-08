{ pkgs, ... }:
{
  programs.gh = {
    enable = true;

    extensions = builtins.attrValues {
      inherit (pkgs)
        # gh-cal # github activity stats in the CLI (not working, maybe we can fix it?)
        gh-copilot # copilot in the CLI
        gh-eco # explore the ecosystem
        ;
    };

    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
    };
  };
}
