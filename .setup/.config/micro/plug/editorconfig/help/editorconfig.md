editorconfig
============

http://editorconfig.org helps developers define and maintain
consistent coding styles between different editors and IDEs.
This is the EditorConfig plugin for the `micro` editor.

This plugin requires an editorconfig core executable to be installed.
https://github.com/editorconfig/editorconfig-core-c


Usage
-----

Once installed, this plugin will automatically use the editorconfig core to
obtain the desired editorconfig properties based on the file, and apply the
corresponding micro options on both open (necessary for things like tabstospaces)
and save (necessary for things like rmtrailingws).

If any micro options have been changed as a result of editorconfig configuration,
they will be logged to micro's debug log. You may view them by running micro in
debug mode (`micro -debug`) and then subsequently inspecting `log.txt`.
