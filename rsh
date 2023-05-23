#!/usr/bin/env ruby
# encoding: utf-8
#
# SCRIPT INFO 
# Name:       RTFM - Ruby Terminal File Manager
# Language:   Pure Ruby, best viewed in VIM
# Author:     Geir Isene <g@isene.com>
# Web_site:   http://isene.com/
# Github:     https://github.com/isene/RTFM
# License:    I release all copyright claims. This code is in the public domain.
#             Permission is granted to use, copy modify, distribute, and sell
#             this software for any purpose. I make no guarantee about the
#             suitability of this software for any purpose and I am not liable
#             for any damages resulting from its use. Further, I am under no
#             obligation to maintain or extend this software. It is provided 
#             on an 'as is' basis without any expressed or implied warranty.
@version    = "0.1"

# MODULES, CLASSES AND EXTENSIONS
class String # Add coloring to strings (with escaping for Readline)
  def c(code);  color(self, "\001\e[38;5;#{code}m\002"); end
  def b;        color(self, "\001\e[1m\002"); end
  def i;        color(self, "\001\e[3m\002"); end
  def u;        color(self, "\001\e[4m\002"); end
  def l;        color(self, "\001\e[5m\002"); end
  def color(text, color_code)  "#{color_code}#{text}\001\e[0m\002" end
end
module Cursor # Terminal cursor movement ANSI codes (thanks to https://github.com/piotrmurach/tty-cursor/tree/master)
  module_function
  ESC = "\e".freeze
  CSI = "\e[".freeze
  def save # Save current position
    print(Gem.win_platform? ? CSI + 's' : ESC + '7')
  end
  def restore # Restore cursor position
    print(Gem.win_platform? ? CSI + 'u' : ESC + '8')
  end
  def pos # Query cursor current position
    res = ''
    $stdin.raw do |stdin|
      $stdout << "\e[6n"
      $stdout.flush
      while (c = stdin.getc) != 'R'
        res << c if c
      end
    end
    m = res.match /(?<row>\d+);(?<col>\d+)/
    return m[:row].to_i, m[:col].to_i
  end
  def up(n = nil) # Move cursor up by n
    print(CSI + "#{(n || 1)}A")
  end
  def down(n = nil) # Move the cursor down by n
    print(CSI + "#{(n || 1)}B")
  end
  def left(n = nil) # Move the cursor backward by n
    print(CSI + "#{n || 1}D")
  end
  def right(n = nil) # Move the cursor forward by n
    print(CSI + "#{n || 1}C")
  end
  def col(n = nil) # Cursor moves to nth position horizontally in the current line
    print(CSI + "#{n || 1}G")
  end
  def row(n = nil) # Cursor moves to the nth position vertically in the current column
    print(CSI + "#{n || 1}d")
  end
  def next_line # Move cursor down to beginning of next line
    print(CSI + 'E' + CSI + "1G")
  end
  def prev_line # Move cursor up to beginning of previous line
    print(CSI + 'A' +  CSI + "1G")
  end
  def clear_char(n = nil) # Erase n characters from the current cursor position
    print(CSI + "#{n}X")
  end
  def clear_line # Erase the entire current line and return to beginning of the line
    print(CSI + '2K' +  CSI + "1G")
  end
  def clear_line_before # Erase from the beginning of the line up to and including the current cursor position.
    print(CSI + '1K')
  end
  def clear_line_after # Erase from the current position (inclusive) to the end of the line
    print(CSI + '0K')
  end
  def scroll_up # Scroll display up one line
    print(ESC + 'M')
  end
  def scroll_down # Scroll display down one line
    print(ESC + 'D')
  end
  def clear_screen_down
    print(CSI + 'J')
  end
end
# INITIALIZATION
begin # Requires
  require 'etc'
  require 'io/console'
end
begin # Initialization
  # Theming
  @c_prompt    = 196                    # Color for basic prompt
  @c_cmd       = 48                     # Color for valid command
  @c_nick      = 51                     # Color for matching nick
  @c_gnick     = 87                     # Color for matching gnick
  @c_path      = 208                    # Color for valid path
  @c_switch    = 148                    # Color for switches/options
  @c_tabselect = 207                    # Color for selected tabcompleted item
  @c_taboption = 244                    # Color for unselected tabcompleted item
  # Prompt
  @user        = Etc.getlogin           # For use in @prompt
  @node        = Etc.uname[:nodename]   # For use in @prompt
  @prompt      = "rsh >".c(@c_prompt).b # Very basic prompt if not defined in .rshrc
  # Hash & array initializations
  @nick        = {}                     # Initiate alias/nick hash
  @gnick       = {}                     # Initiate generic/global alias/nick hash
  @history     = []                     # Initiate history array
  # Paths
  @path        = ["/bin", 
                  "/usr/bin", 
                  "/home/#{@user}/bin"] # Basic paths for executables if not set in .rshrc
  # History
  @histsize    = 100                    # Max history if not set in .rshrc
  @hloaded     = false                  # Variable to determine if history is loaded
  # Variable initializations
  @cmd         = ""                     # Initiate variable @cmd
end
# GENERIC FUNCTIONS
def getchr # Process key presses
  c = STDIN.getch
  case c
  when "\e"    # ANSI escape sequences
    case $stdin.getc
    when '['   # CSI
      case $stdin.getc
      when 'A' then chr = "UP"
      when 'B' then chr = "DOWN"
      when 'C' then chr = "RIGHT"
      when 'D' then chr = "LEFT"
      when 'Z' then chr = "S-TAB"
      when '2' then chr = "INS"    ; chr = "C-INS"    if STDIN.getc == "^"
      when '3' then chr = "DEL"    ; chr = "C-DEL"    if STDIN.getc == "^"
      when '5' then chr = "PgUP"   ; chr = "C-PgUP"   if STDIN.getc == "^"
      when '6' then chr = "PgDOWN" ; chr = "C-PgDOWN" if STDIN.getc == "^"
      when '7' then chr = "HOME"   ; chr = "C-HOME"   if STDIN.getc == "^"
      when '8' then chr = "END"    ; chr = "C-END"    if STDIN.getc == "^"
      end
    when 'O'   # Set Ctrl+ArrowKey equal to ArrowKey; May be used for other purposes in the future
      case $stdin.getc
      when 'a' then chr = "C-UP"
      when 'b' then chr = "C-DOWN"
      when 'c' then chr = "C-RIGHT"
      when 'd' then chr = "C-LEFT"
      end
    end
  when "", "" then chr = "BACK"
  when "" then chr = "C-C"
  when "" then chr = "C-D"
  when "" then chr = "C-G"
  when "" then chr = "C-K"
  when "" then chr = "C-L"
  when "" then chr = "C-N"
  when "" then chr = "C-O"
  when "" then chr = "C-P"
  when "" then chr = "C-T"
  when "" then chr = "C-Y"
  when "" then chr = "WBACK"
  when "" then chr = "LDEL"
  when "\r" then chr = "ENTER"
  when "\t" then chr = "TAB"
  when /./  then chr = c
  end
  return chr
end
def getstr # A custom Readline-like function
  @stk = 0
  @pos  = 0
  chr  = ""
  @history.insert(0, "")
  @history_copy = @history.map(&:clone)
  while chr != "ENTER" # Keep going with readline until user presses ENTER
    text = @history_copy[@stk]
    @c.clear_line
    print @prompt
    row, pos0 = @c.pos
    print cmd_check(text)
    @c.col(pos0 + @pos)
    chr = getchr
    return "\n" if chr == "C-G" # Ctrl-G escapes the reasdline
    case chr
    when 'C-C'   # Ctrl-C exits gracefully but without updating .rshrc
      print "\n"
      exit
    when 'C-D'   # Ctrl-D exits after updating .rshrc
      rshrc
      exit
    when 'C-L'   # Clear screen and set position to top of the screen
      @c.row(1)
      @c.clear_screen_down
    when 'UP'    # Go up in history
      unless @stk >= @history_copy.length - 1
        @stk += 1 
        @pos = @history_copy[@stk].length
      end
    when 'DOWN'  # Go down in history
      unless @stk == 0
        @stk -= 1 
        @pos = @history_copy[@stk].length
      end
    when 'RIGHT' # Move right on the readline
      @pos += 1 unless @pos >= @history_copy[@stk].length
    when 'LEFT'  # Move left on the readline
      @pos -= 1 unless @pos <= 0
    when 'HOME'  # Go to beginning of the readline
      @pos = 0
    when 'END'   # Go to the end of the readline
      @pos = @history_copy[@stk].length
    when 'DEL'   # Delete one character
      @history_copy[@stk][@pos] = ""
    when 'BACK'  # Delete one character to the left
      unless @pos <= 0
        @pos -= 1
        @history_copy[@stk][@pos] = ""
      end
    when 'WBACK' # Delete one word to the left (Ctrl-W)
      unless @pos == pos0
        until @history_copy[@stk][@pos - 1] == " " or @pos == 0
          @pos -= 1
          @history_copy[@stk][@pos] = ""
        end
        if @history_copy[@stk][@pos - 1] == " "
          @pos -= 1
          @history_copy[@stk][@pos] = ""
        end
      end
    when 'C-K'   # Kill/delete that entry in the history
      @history_copy.delete_at(@stk)
      @history.delete_at(@stk)
      @stk -= 1
      @pos  = @history_copy[@stk].length
    when 'LDEL'  # Delete readline (Ctrl-U)
      @history_copy[@stk] = ""
      @pos = 0
    when 'TAB'   # Tab completion of dirs and files
      @tabstr  = @history_copy[@stk][0...@pos]
      @tabend  = @history_copy[@stk][@pos..]
      elements = @tabstr.split(" ")
      elements.append("") if @tabstr.match(" $")
      i = elements.length - 1
      m = elements[i].to_s
      if m == "-"
        until i == 0
          i -= 1
          if elements[i] !~ /^-/
            @tabstr.chop!
            tab_switch(elements[i])
            break
          end
        end
      else
        tab_all(m)
      end
      @history_copy[@stk] = @tabstr + @tabend
    when /^.$/
      @history_copy[@stk].insert(@pos,chr)
      @pos += 1
    end
  end
  @history.insert(0, @history_copy[@stk])
  @history[0]
end
def tab_switch(str) # TAB completion for command switches (TAB after "-")
  hlp = `#{str} --help`
  hlp = hlp.split("\n").grep(/^\s*-{1,2}[^-]/)
  hlp = hlp.map {|h| h.sub(/^\s*/, '')}
  switch, tab = tabselect(hlp)
  switch = switch.sub(/ .*/, '').sub(/,/, '')
  @tabstr += switch
  @pos = @tabstr.length
end
def tab_all(str) # TAB completion for Dirs/files, nicks and commands
  exe = []
  @path.each do |p|
    Dir.glob(p).each do |c| 
      exe.append(File.basename(c)) if File.executable?(c) and not Dir.exist?(c)
    end
  end
  exe.prepend(*@nick.keys)
  exe.prepend(*@gnick.keys)
  compl = exe.select {|s| s =~ Regexp.new("^" + str)}
  fdir = File.expand_path(str)
  fdir += "/" if Dir.exist?(fdir)
  fdir += "*"
  compl.prepend(*Dir.glob(fdir))
  @tabstr = @tabstr.sub(/#{str}$/, '') unless compl.empty?
  match, tab = tabselect(compl) unless compl.empty?
  @tabstr += match if match
  @tabstr += str if match == ""
  @pos = @tabstr.length if match
end
def nextline # Handle going to the next line in the terminal
  row, col = @c.pos
  if row == @maxrow
    @c.scroll_down
    @c_row -= 1
  end
  @c.next_line
end
def tabselect(ary) # Let user select from the incoming array
  @c_row, @c_col = @c.pos
  chr = ""
  tab = false
  i = 0
  ary.length < 5 ? l = ary.length : l = 5
  while chr != "ENTER"
    @c.clear_screen_down
    l.times do |x|
      if x == 0
        @c.clear_line
        print "#{@prompt}#{@tabstr}#{ary[i].sub(/(.*?)[ ,].*/, '\1')}#{@tabend}" 
        nextline
        print " #{ary[i]}".c(@c_tabselect)
      else
        print " #{ary[x+i]}".c(@c_taboption)
      end
      nextline
    end
    @c.row(@c_row)
    @c.col(@c_col)
    chr = getchr
    case chr
    when 'C-G', 'C-C'
      @c.clear_screen_down
      return ""
    when 'DOWN'
      i += 1 unless i > ary.length - 2
    when 'UP'
      i -= 1 unless i == 0
    when'TAB'
      chr = "ENTER"
      tab = true
    end
  end
  @c.clear_screen_down
  @c.row(@c_row)
  @c.col(@c_col)
  return ary[i], tab
end
def hist_clean # Clean up @history
  @history.uniq!
  @history.compact!
  @history.delete("")
end
def cmd_check(str) # Check if each element on the readline matches commands, nicks, paths; color them
  str.gsub(/\S+/) do |el|
    if @nick.include?(el)
      el.c(@c_nick)
    elsif @gnick.include?(el)
      el.c(@c_gnick)
    elsif File.exists?(el.sub(/^~/, "/home/#{@user}"))
      el.c(@c_path)
    elsif system "which #{el}", %i[out err] => File::NULL
      el.c(@c_cmd)
    elsif el =~ /^-/
      el.c(@c_switch)
    else
      el
    end
  end
end
def rshrc # Write updates to .rshrc
  hist_clean
  if File.exist?(Dir.home+'/.rshrc')
    conf = File.read(Dir.home+'/.rshrc')
  else
    conf = ""
  end
  conf.sub!(/^@nick.*\n/, "") 
  conf += "@nick = #{@nick}\n"
  conf.sub!(/^@gnick.*\n/, "") 
  conf += "@gnick = #{@gnick}\n"
  conf.sub!(/^@history.*\n/, "") 
  conf += "@history = #{@history.last(@histsize)}\n"
  File.write(Dir.home+'/.rshrc', conf)
  puts "\n .rshrc updated"
end
# RSH FUNCTIONS
def history # Show history
  puts "History:"
  puts @history
end
def rmhistory # Delete history
  @history = []
  puts "History deleted."
end
def nick(nick_str)  # Define a new nick like this: `:nick "ls = ls --color"`
  if nick_str.match(/^\s*-/)
    source = nick_str.sub(/^\s*-/, '')
    @nick.delete(source)
  else
    source = nick_str.sub(/ =.*/, '')
    target = nick_str.sub(/.*= /, '')
    @nick[source] = target
  end
  rshrc
end
def gnick(nick_str) # Define a generic/global nick to match not only commands (format like nick)
  if nick_str.match(/^\s*-/)
    source = nick_str.sub(/^\s*-/, '')
    @gnick.delete(source)
  else
    source = nick_str.sub(/ =.*/, '')
    target = nick_str.sub(/.*= /, '')
    @gnick[source] = target
  end
  rshrc
end
def nick? # Show nicks
  puts "  Command nicks:".c(@c_nick)
  @nick.each {|key, value| puts "  #{key} = #{value}"}
  puts "  General nicks:".c(@c_gnick)
  @gnick.each {|key, value| puts "  #{key} = #{value}"}
end

# INITIAL SETUP
begin # Load .rshrc and populate @history
  trap "SIGINT" do print "\n"; exit end
  load(Dir.home+'/.rshrc') if File.exist?(Dir.home+'/.rshrc') # Initial loading - to get history
  @c = Cursor               # Initiate @c as Cursor
  @c.save                   # Get max row & col
  @c.row(8000)
  @c.col(8000)
  @maxrow, @maxcol = @c.pos
  @c.restore                # Max row & col gotten, cursor restored
  hist_clean                # Remove duplicates, etc
  @path.map! {|p| p + "/*"} # Set proper format for path search
end

# MAIN PART
loop do 
  h = @history; load(Dir.home+'/.rshrc') if File.exist?(Dir.home+'/.rshrc'); @history = h # reload prompt but not history
  @prompt.gsub!(/#{Dir.home}/, '~') # Simplify path in prompt
  @cmd = getstr # Main work is here
  hist_clean # Clean up the history
  @cmd = "ls" if @cmd == "" # Default to ls when no command is given
  print "\n" # Newline
  if @cmd == "x" then rshrc; break; end # A simple way to exit rsh
  if @cmd == "r" # Integration with rtfm (https://github.com/isene/RTFM)
    File.write("/tmp/.rshpwd", Dir.pwd)
    system("rtfm /tmp/.rshpwd")
    Dir.chdir(File.read("/tmp/.rshpwd"))
    next
  end
  begin # Execute command
    if @cmd.match(/^\s*:/) # Ruby commands are prefixed with ":"
      eval(@cmd[1..-1])
    else
      begin # Try cd to cmd
        @cmd.sub!(/^cd (\S*).*/, '\1')
        @cmd = Dir.home if @cmd == "~"
        Dir.chdir(@cmd.strip.sub(/~/, Dir.home))
      rescue # If cd fails, execute cmd (unless no such cmd)
        ca = @nick.transform_keys {|k| /((^\K\s*\K)|(\|\K\s*\K))\b(?<!-)#{Regexp.escape k}\b/}
        @cmd = @cmd.gsub(Regexp.union(ca.keys), @nick)
        ga = @gnick.transform_keys {|k| /\b#{Regexp.escape k}\b/}
        @cmd = @cmd.gsub(Regexp.union(ga.keys), @gnick)
        puts "#{Time.now.strftime("%H:%M:%S")}: #{@cmd}".c(244)
        begin
          if @cmd == "fzf" # fzf integration (https://github.com/junegunn/fzf)
            res = `#{@cmd}`.chomp
            Dir.chdir(File.dirname(res))
          elsif system(@cmd) # Try execute the command
          else
            puts "No such command: #{@cmd}"
          end
        rescue
          if File.exist?(@cmd) # Try to open file with user's editor
            system("#{ENV['EDITOR']} #{@cmd}")
          end
        end
      end
    end
  rescue StandardError => err # Throw error nicely
    puts "#{err}"
  end
end

# vim: set sw=2 sts=2 et fdm=syntax fdn=2 fcs=fold\:\ :
