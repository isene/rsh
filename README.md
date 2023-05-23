# rsh
The Ruby SHell

# Why?
Ruby is my goto language (pun kinda intended). I want full control over my tools and I like challenges that I can tinker with late at night. This is an incomplete project continually being improved. Feel free to add suggestions or code.

# Design principles
Simple. One file. Minimum external requirements.

# Installation
Clone this repo and drop `rsh` into your preferred bin directory. Drop `.rshrc` into your home directory and edit as you see fit.

Or simply `gem install ruby-shell`.

# Features
* Aliases (called `nicks`in rsh) - both for commands and general nicks
* Syntax highlighting, matching nicks, system commands and valid dirs/files
* Tab completions for nicks, system commands, command switches and dirs/files
* Tab completion presents matches in a list to pick from
* History with simple editing
* Config file (`.rshrc`) updates on exit
* Set of simple rsh specific commands like `nick`, `nick?`, `history` and `rmhistory`
* rsh specific commands and full set of Ruby commands available via `:command`
* All colors are themeable in `.rshrc`

## Nicks
Add command nicks (aliases) with `:nick "some_nick = some_command"`, e.g. `:nick "ls = ls --color"`. Add general nicks that will substitute anything on a command line (not just commands) like this `:gnick "some_gnick = some_command"`, e.g. `:gnick "x = /home/user/somewhere"`. List (g)nicks with `:nick?`. Remove a nick with `:nick "-some_command"`, e.g. `:nick "-ls"` to remove an `ls` nick. Same for gnicks.

## Tab completion
You can tab complete almost anything. Hitting `TAB` will try to complete in this priority: nicks, gnicks, commands, dirs/files. Hitting `TAB`after a `-` will list the command switches for the preceding command with a short explanation (from the command's --help), like this `ls -`(`TAB`) will list all the switches/options for the `ls` command.

## Syntax highlighting
rsh will highlight nicks, gnicks, commands and dirs/files as they are written on the command line.

## Theming
In the supplied `.rshrc`, you will find a set of colors that you can change:

Variable        | Description
----------------|-----------------------------------------
`@c_prompt`     | Color for basic prompt
`@c_cmd`        | Color for valid command
`@c_nick`       | Color for matching nick
`@c_gnick`      | Color for matching gnick
`@c_path`       | Color for valid path
`@c_tabselect`  | Color for selected tabcompleted item
`@c_taboption`  | Color for unselected tabcompleted item

# Enter the world of Ruby
By entering `:some-ruby-command` you have full access to the Ruby universe right from your command line. You can do anything from `:puts 2 + 13` or `:if 0.7 > Math::sin(34) then puts "OK" end` or whatever tickles you fancy.

# Not yet implemented
Lots. Of. Stuff.

Most notably; You cannot paste onto the command line yet.

# License and copyright
Forget it.
