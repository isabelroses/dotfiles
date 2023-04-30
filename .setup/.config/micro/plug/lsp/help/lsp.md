# Micro Plugin LSP Client

LSP is a Language Server Protocol client. Features include function signatures
and jump to definition.

This help page can be viewed in Micro editor with Ctrl-E 'help lsp'

## Features and Shortcuts

- Show function signature on status bar (alt-K) (textDocument/hover)
- Open function definition in a new tab (alt-D) (textDocument/definition)
- Format document (alt-F) (textDocument/formatting)
- Show references to the current symbol in a buffer (alt-R)
  (textDocument/references), pressing return on the reference line, the
  reference's location is opened in a new tab

There is initial support for completion (ctrl-space) (textDocument/completion).

## Supported languages

Installation instructions for Go and Python are provided below. LSP Plugin has
been briefly tested with

- C++: [clangd](https://clangd.llvm.org) /
  [ccls](https://github.com/MaskRay/ccls)
- go: [gopls](https://pkg.go.dev/golang.org/x/tools/gopls#section-readme)
- markdown, JSON, typescript, javascript (including JSX/TSX):
  [deno](https://deno.land/)
- python: pyls and [pylsp](https://github.com/python-lsp/python-lsp-server)
- rust: [rls](https://github.com/rust-lang/rls)
- lua: [lua-lsp](https://github.com/Alloyed/lua-lsp)

## Install LSP plugin

    $ micro --plugin install lsp

To configure the LSP Plugin, you can add two lines to settings.json

    $ micro settings.json

Add lines

```json
{
  "lsp.server": "python=pylsp,go=gopls,typescript=deno lsp={\"importMap\": \"./import_map.json\"}",
  "lsp.formatOnSave": true
}
```

Remember to add comma to previous line. Depending on the language server,
automatic code formating can be quite opinionated. In that case, you can simply
set lsp.formatOnSave to false.

For Python language server, the currently maintained fork is 'pylsp'. If you
wish to use the Palantir version (last updated in 2020) instead, set
"python=pyls" in lsp.server.

If your lsp.server settings are autoremoved, you can

    $ export MICRO_LSP='python=pylsp,go=gopls,typescript=deno lsp={"importMap":"import_map.json"},rust=rls'

The lsp.server default settings (if no others are defined) are:

```
python=pylsp,go=gopls,typescript=deno lsp,javascript=deno lsp,markdown=deno lsp,json=deno lsp,jsonc=deno lsp,rust=rls,lua=lua-lsp,c++=clangd
```

## Install Language Server

To support each language, LSP plugin uses language servers. To use LSP plugin,
you must install at least one language server.

If you want to quickly test LSP plugin, Go language server gopls is simple to
install.

### gopls, Go language server

You will need command 'gopls'

    $ gopls version
    golang.org/x/tools/gopls v0.7.3

In Debian, this is installed with

    $ sudo apt-get update
    $ sudo apt-get -y install golang-go gopls

To test it, write a short go program

    $ micro hello.go

```go
package main

import "fmt"

func main() {
	fmt.Println("hello world")
}
```

Move cursor over Println and press alt-k. The function signature is shown on the
bottom of the screen, in Micro status bar. It shows you what parameters the
function can take. The signature should look similar to this: "func
fmt.Println(a ...interface{}) (n int, err error)Println formats using the
default formats..."

Can you see the function signature with alt-k? If you can, you have succesfully
installed Micro LSP plugin and GoPLS language server.

Keep your cursor over Println, and press alt-d. The file defining Println opens.
In this case, it's fmt/print.go. As Go reference documentation is in code
comments, this is very convenient. You can navigate between tabs with atl-,
(alt-comma) and alt-. (alt - full stop). To close the tab, press Ctrl-Q.

### Markdown, JSON/JSONC, Typescript, Javascript

The Deno LSP server will provide full support for Typescript and Javascript.
Additionally, it supports formatting for Markdown and JSON files. The
installation of this is fairly straight forward:

On Mac/Linux:

    $ curl -fsSL https://deno.land/install.sh | sh

On Powershell:

    $ iwr https://deno.land/install.ps1 -useb | iex

### typescript-language-server

This LSP server will allow for Javascript as well as Typescript support. For
using it, you first need to install it using NPM:

    $ npm install -g typescript-language-server typescript

Once it has been installed, you can use it like so:

    $ micro hello.js

Press ctrl-e and type in:

    set lsp.server "typescript=typescript-language-server --stdio,javascript=typescript-language-server --stdio"

After you restarted micro, you can use the features for typescript and
javascript accordingly.

### pylsp, Python language server

Installing Python language server PyLSP is a bit more involved.

You will need 'virtualenv' command to create virtual environments and 'pip' to
install Python packages. You can also use one of the many other commands for
keeping your 'pip' packages in order.

In Debian, these are installed with

    $ sudo apt-get update
    $ sudo apt-get install python-pip virtualenv

Create a new virtual environment

    $ mkdir somePythonProject; cd somePythonProject
    $ virtualenv -p python3 env/
    $ source env/bin/activate

Your prompt likely shows "(env)" to confirm you're inside your virtual
environment.

List the packages you want installed.

    $ micro requirements.txt

This list is to provide the most useful suggestions. If you would like to get a
lot more opinionated advice, such as adding two empty lines between functions,
you could use "python-lsp-server[all]". The mypy package provides optional
static type checking. requirements.txt:

```
python-lsp-server[rope,pyflakes,mccabe,pylsp-mypy]
pylsp-mypy
```

And actually install

    $ pip install -r requirements.txt

No you can test your Python environment

    $ micro hello.py

```python
def helloWorld():
	return a
```

Save with Ctrl-S. A red warning sign ">>" lists up in the gutter, on the left
side of Micro. Move cursor to the line "return a". The status bar shows the
warning: "undefined name 'a'". Well done, you have now installed Python LSP
support for Micro.

MyPy provides optional static type setting. You can write normally, and type
checking is ignored. You can define types for some functions, and you get
automatic warnings for incorrect use of types. This is how types are marked:

```python
def square(x: int) -> int:
	return x*x
```

Depending on your project, taste and installed linters, pylsp sometimes shows
warnings you would like to hide. Hiding messages is possible using
lsp.ignoreMessages, explained in later in this help document.

### lua-lsp, Lua language server

These are the initial installation instructions. This installation will support
linter messages in the gutter (on the left of editing area) and jump to
definition inside the same file (alt-D). All LSP features are not yet supported
with Lua.

Install 'luarocks' command using your package manager. For example, on Debian

    $ sudo apt-get update
    $ sudo apt-get -y install luarocks

Use luarocks to install helper packages used by lua-lsp

    $ sudo luarocks install luacheck
    $ sudo luarocks install Formatter
    $ sudo luarocks install lcf

Install lua-lsp, the Lua language server

    $ sudo luarocks install --server=ssh://luarocks.org/dev lua-lsp

This command uses different URL from official lua-lsp instructions due to
[a change in how packages are downloaded](https://github.com/Alloyed/lua-lsp/issues/45).
This command uses ssh instead of http.

To test it, open a Lua file

    $ micro $HOME/.config/micro/plug/lsp/main.lua

Can you see some linter warnings ">>" in the gutter? Can you jump to functions
inside the same file with Alt-D? Well done, you've installed Lua LSP support for
micro.

All features don't work yet with Lua LSP.

### zls, ZIG language server

The ZIG language server provides formatting, goto definition, auto-completion as
well as hover and references. It can be installed by following
[these instruction](https://github.com/zigtools/zls).

Once installed, open micro, press ctrl+e and type the following command:

    set lsp.server zig=zls

Close micro again and open a zig file.

## Ignoring unhelpful messages

In addition to providing assistance while coding, some language servers can show
spurious, unnecessary or too oppinionated messages. Sometimes, it's not obvious
how these messages are disable using language server settings.

This plugin allows you to selectively ignore unwanted warnings while keeping
others. This is done my matching the start of the message. By default, nothing
is ignored.

Consider a case where you're working with an external Python project that
indents with tabs. When joining an existing project, you might not want to
impose your own conventions to every code file. On the other hand, LSP support
is not useful if nearly every line is marked with a warning.

Moving the cursor to a line with the warning, you see that the line starts with
"W191 indentation contains tabs". This, and similar unhelpful messages (in the
context of your current project) can be ignored by editing
~/.config/micro/settings.json

```json
{
  "lsp.ignoreMessages": "Skipping analyzing |W191 indentation contains tabs|E101 indentation contains mixed spaces and tabs|See https://mypy.readthedocs.io/en"
}
```

As you now open the same file, you can see that warning "W191 indentation
contains tabs" is no longer shown. Also the warning mark ">>" in the gutter is
gone. Try referring to a variable that does not exist, and you can see a helpful
warning appear. You have now disabled the warnings you don't need, while keeping
the useful ones.

## See also

[Official repostory](https://github.com/AndCake/micro-plugin-lsp)

[Usage examples with screenshots](https://terokarvinen.com/2022/micro-editor-lsp-support-python-and-go-jump-to-definition-show-function-signature/)

[Language Server Protocol](https://microsoft.github.io/language-server-protocol/)

[gopls - the Go language server](https://pkg.go.dev/golang.org/x/tools/gopls)

[pylsp - Python LSP Server](https://github.com/python-lsp/python-lsp-server)

[mypy - Optional Static Typing for Python](http://mypy-lang.org/)

[rls - Rust Language Server](https://github.com/rust-lang/rls)

[deno](https://deno.land/)

[typescript-language-server](https://www.npmjs.com/package/typescript-language-server)

[lua-lsp - A Lua language server](https://github.com/Alloyed/lua-lsp)
