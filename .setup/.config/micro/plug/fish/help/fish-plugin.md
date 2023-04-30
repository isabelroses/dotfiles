# Fish Plugin

The fish plugin provides some extra niceties for using micro with the fish
scripting language. The main thing this plugin does is run `fish_indent` for you
automatically.

You can run

```
> fishfmt
```

To automatically run it when you save the file, use the following option:

* `fishfmt`: run fish_indent on file saved. Default value: `on`
