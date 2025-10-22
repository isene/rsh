Gem::Specification.new do |s|
  s.name        = 'ruby-shell'
  s.version     = '3.0.0'
  s.licenses    = ['Unlicense']
  s.summary     = "rsh - Ruby SHell"
  s.description = "A shell written in Ruby with extensive tab completions, aliases/nicks, history, syntax highlighting, theming, auto-cd, auto-opening files and more. UPDATE v3.0.0: MAJOR RELEASE - Persistent defuns, smart command suggestions with typo detection, command analytics with :stats, switch caching, enhanced bookmarks with tags, session save/restore, syntax validation, option value completion, and performance tracking."
  s.authors     = ["Geir Isene"]
  s.email       = 'g@isene.com'
  s.files       = ["bin/rsh", "README.md", ".rshrc"]
  s.executables << 'rsh'
  s.homepage    = 'https://isene.com/'
  s.metadata    = { "source_code_uri" => "https://github.com/isene/rsh" }
end
