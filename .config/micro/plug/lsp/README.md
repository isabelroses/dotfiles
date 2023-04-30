# Micro Plugin LSP Client

**Please note:** This software is very much not finished. It is more like a
proof of concept and might break if you call it names.

Provides LSP methods as actions to Micro that can subsequently be mapped to key
bindings.

Currently implemented methods:

- textDocument/hover
- textDocument/definition
- textDocument/completion
- textDocument/formatting
- textDocument/references

If possible, this plugin will register the following shortcuts:

- Alt-k for hover
- Alt-d for definition lookup
- Alt-f for formatting
- Alt-r for looking up references
- Ctrl-space for completion

## Installation

Clone this repo into micro's plug folder:

```
$ git clone https://github.com/AndCake/micro-plugin-lsp ~/.config/micro/plug/lsp
```

## Configuration

In your `settings.json`, you add the `lsp.server` option in order to enable
using it for your languages' server.

Example:

```
{
	"lsp.server": "python=pyls,go=gopls,typescript=deno lsp,rust=rls",
	"lsp.formatOnSave": true,
	"lsp.ignoreMessages": "LS message1 to ignore|LS message 2 to ignore|...",
	"lsp.tabcompletion": true,
	"lsp.ignoreTriggerCharacters": "completion,signature",
	"lsp.autocompleteDetails": false
}
```

The format for the `lsp.server` value is a comma-separated list for each file
type you want to boot up a language server:

```
<file type>=<executable with arguments where necessary>[=<initialization options passed to language server>][,...]
```

You can also use an environment variable called `MICRO_LSP` to define the same
information. If set, it will override the `lsp.server` from the `settings.json`.
You can add a line such as the following to your shell profile (e.g. .bashrc):

```
export MICRO_LSP='python=pyls,go=gopls,typescript=deno lsp={"importMap":"import_map.json"},rust=rls'
```

If neither the MICRO_LSP nor the lsp.server is set, then the plugin falls back
to the following settings:

```
python=pylsp,go=gopls,typescript=deno lsp,javascript=deno lsp,markdown=deno lsp,json=deno lsp,jsonc=deno lsp,rust=rls,lua=lua-lsp,c++=clangd
```

The option `lsp.autocompleteDetails` allows for showing all auto-completions in
a horizontally split buffer view (true) instead of the status line (false).

## Testing

This plugin has been tested briefly with the following language servers:

- C++ [clangd](https://clangd.llvm.org) /
  [ccls](https://github.com/MaskRay/ccls)
- go: [gopls](https://pkg.go.dev/golang.org/x/tools/gopls#section-readme)
- markdown, JSON, typescript, javascript (including JSX/TSX):
  [deno](https://deno.land/)
- python: pyls, [pylsp](https://github.com/python-lsp/python-lsp-server)
- rust: [rls](https://github.com/rust-lang/rls)
- lua: [lua-lsp](https://github.com/Alloyed/lua-lsp)
- zig: [zls](https://github.com/zigtools/zls)

## Known issues

Not all possible types of modification events to the file are currently being
sent to the language server. Saving the file will re-synchronize it, though.
