# rsh
![Ruby](https://img.shields.io/badge/language-Ruby-red) [![Gem Version](https://badge.fury.io/rb/ruby-shell.svg)](https://badge.fury.io/rb/ruby-shell) ![Unlicense](https://img.shields.io/badge/license-Unlicense-green) ![Stay Amazing](https://img.shields.io/badge/Stay-Amazing-important)

The Ruby SHell

# Why?
Ruby is my goto language (pun kinda intended). I want full control over my tools and I like challenges that I can tinker with late at night. This is an incomplete project continually being improved. Feel free to add suggestions or code.

# Design principles
Simple. One file. Minimum external requirements.

# Installation
Clone this repo and drop `rsh` into your preferred bin directory. Drop `.rshrc` into your home directory and edit as you see fit.

Or simply `gem install ruby-shell`.

# Features
* Aliases (called nicks in rsh) - both for commands and general nicks
* Syntax highlighting, matching nicks, system commands and valid dirs/files
* Tab completions for nicks, system commands, command switches and dirs/files
* Tab completion presents matches in a list to pick from
* When you start to write a command, rsh will suggest the first match in the history and present that in "toned down" letters - press the arrow right key to accept the suggestion.
* History with editing, search
* Config file (.rshrc) updates on exit (with Ctrl-d) or not (with Ctrl-c)
* Set of simple rsh specific commands like nick, nick?, history and rmhistory
* rsh specific commands and full set of Ruby commands available via :<command>
* All colors are themeable in .rshrc (see github link for possibilities)
  
Special functions/integrations:
* Use `r` to launch rtfm (https://github.com/isene/RTFM) - if you have it installed
* Use `f` to launch fzf (https://github.com/junegunn/fzf) - if you have it installed
* Use `=` followed by xrpn commands separated by commas (https://github.com/isene/xrpn)
* Use `:` followed by a Ruby expression to access the whole world of Ruby

Special commands:
* `:nick 'll = ls -l'` to make a command alias (ll) point to a command (ls -l)
* `:gnick 'h = /home/me'` to make a general alias (h) point to something (/home/me)
* `:nick?` will list all command nicks and general nicks (you can edit your nicks in .rshrc)
* `:history` will list the command history, while `:rmhistory` will delete the history
* `:help` will display this help text

## Moving around
While you `cd` around to different directories, you can see the last 10 directories visited via the command `:dirs` or the convenient shortcut `#`. Entering the number in the list (like `6` and ENTER) will jump you to that directory. Entering `-` will jump you back to the previous dir (equivalent of `1`. Entering `~` will get you to your home dir. If you want to bookmark a special directory, you can do that via a general nick like this: `:gnick "x = /path/to/a/dir/"` - this would bookmark the directory to the single letter `x`.

## Nicks
Add command nicks (aliases) with `:nick "some_nick = some_command"`, e.g. `:nick "ls = ls --color"`. Add general nicks that will substitute anything on a command line (not just commands) like this `:gnick "some_gnick = some_command"`, e.g. `:gnick "x = /home/user/somewhere"`. List (g)nicks with `:nick?`. Remove a nick with `:nick "-some_command"`, e.g. `:nick "-ls"` to remove an `ls` nick. Same for gnicks.

## Tab completion
You can tab complete almost anything. Hitting `TAB` will try to complete in this priority: nicks, gnicks, commands, dirs/files. Hitting `TAB`after a `-` will list the command switches for the preceding command with a short explanation (from the command's --help), like this `ls -`(`TAB`) will list all the switches/options for the `ls` command. You can add to (or subtract from) the search criteria while selecting possible matches - hit any letter to specify the search, while backspace removes a letter from the search criteria. 

Hitting Shift-TAB will do a similar search through the command history - but with a general match of the search criteria (not only matching at the start).

## Integrations
rsh is integrated with the [rtfm file manager](https://github.com/isene/RTFM), with [fzf](https://github.com/junegunn/fzf) and with the programming language [XRPN](https://github.com/isene/xrpn). 

Just enter the command `r` and rtfm will be launched - and when you quit the file manager, you will drop back into rsh in the directory you where you exited rtfm. 

Enter the command `f` to launch the fuzzy finder - select the directory/file you want, press `ENTER` and you will find yourself in the directory where that item resides. 

If you start a line with "=", the rest of the line will be interpreted as an XRPN program. This gives you the full power of XRPN right at your fingertips. You can do simple stuff like this: `=13,23,*,x^2` and the answer to `(13 * 23)^2` will be given (89401) in the format that you have set in your `.xrpn/conf`. Or you can do more elaborate stuff like `=fix 6,5,sto c,time,'Time now is: ',atime,aview,pse,fix 0,lbl a,rcl c,prx,dse c,gto a`. Go crazy. Use single-quotes for any Alpha entry.

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
`@c_stamp`      | Color for time stamp/command

# Open files
If you press `ENTER` after writing or tab-completing to a file, rsh will try to open the file in the user's EDITOR of choice (if it is a valid text file) or use `xdg-open` to open the file using the correct program. If you, for some reason want to use `run-mailcap` instead of `xdg-open` as the file opener, simply add `@runmailcap = true` to your `.rshrc`.

# Enter the world of Ruby
By entering `:some-ruby-command` you have full access to the Ruby universe right from your command line. You can do anything from `:puts 2 + 13` or `:if 0.7 > Math::sin(34) then puts "OK" end` or whatever tickles you fancy.

# Not yet implemented
Lots. Of. Stuff.

# License and copyright
Forget it.
