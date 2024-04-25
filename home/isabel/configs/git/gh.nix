{
  pkgs,
  self',
  ...
}: {
  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;

    extensions = with pkgs; [
      gh-cal # github activity stats in the CLI
      gh-copilot # copilot in the CLI
      self'.packages.gh-eco # explore the ecosystem - use my fork since the main version is broken lel
    ];

    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
    };
  };
}
