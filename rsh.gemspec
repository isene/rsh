Gem::Specification.new do |s|
  s.name        = 'ruby-shell'
  s.version     = '3.4.6'
  s.licenses    = ['Unlicense']
  s.summary     = "rsh - Ruby SHell"
  s.description = "A shell written in Ruby with extensive tab completions, aliases/nicks, history, syntax highlighting, theming, auto-cd, auto-opening files and more. UPDATE v3.4.6: PLUGIN SYSTEM ENHANCED - Plugin help system, 4 new plugins (venv/extract/docker/clipboard), plugins disabled by default. Plus v3.4.5: Full LS_COLORS compliance with pattern-based directory coloring (@dir_colors like RTFM's @topmatch)!"
  s.authors     = ["Geir Isene"]
  s.email       = 'g@isene.com'
  s.files       = ["bin/rsh", "README.md", "PLUGIN_GUIDE.md", ".rshrc"]
  s.executables << 'rsh'
  s.homepage    = 'https://isene.com/'
  s.metadata    = { "source_code_uri" => "https://github.com/isene/rsh" }
end
