{
  programs.git.ignores = [
    # system residue
    ".cache/"
    ".DS_Store"
    ".Trashes"
    ".Trash-*"
    "*.bak"
    "*.swp"
    "*.swo"
    "*.elc"
    ".~lock*"

    # build residue
    "tmp/"
    "target/"
    "result"
    "result-*"
    "*.exe"
    "*.exe~"
    "*.dll"
    "*.so"
    "*.dylib"

    # ide residue
    ".idea/"
    ".vscode/"

    # dependencies
    ".direnv/"
    "node_modules"
    "vendor"
  ];
}
