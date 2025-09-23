Gem::Specification.new do |s|
  s.name        = 'ruby-shell'
  s.version     = '2.11.0'
  s.licenses    = ['Unlicense']
  s.summary     = "rsh - Ruby SHell"
  s.description = "A shell written in Ruby with extensive tab completions, aliases/nicks, history, syntax highlighting, theming, auto-cd, auto-opening files and more. UPDATE v2.11.0: Major TAB completion overhaul! Smart context-aware completion (cd shows only dirs, vim shows only files), frequency-based command scoring, fuzzy matching with fallback, configurable completion options, performance optimizations with executable caching, environment variable completion, better error handling, and much more. A significant improvement to daily shell usage!"
  s.authors     = ["Geir Isene"]
  s.email       = 'g@isene.com'
  s.files       = ["bin/rsh", "README.md", ".rshrc"]
  s.executables << 'rsh'
  s.homepage    = 'https://isene.com/'
  s.metadata    = { "source_code_uri" => "https://github.com/isene/rsh" }
end
