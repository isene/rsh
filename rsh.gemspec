Gem::Specification.new do |s|
  s.name        = 'ruby-shell'
  s.version     = '3.1.0'
  s.licenses    = ['Unlicense']
  s.summary     = "rsh - Ruby SHell"
  s.description = "A shell written in Ruby with extensive tab completions, aliases/nicks, history, syntax highlighting, theming, auto-cd, auto-opening files and more. UPDATE v3.1.0: Multiple named sessions, stats export (CSV/JSON), session auto-save, bookmark import/export, bookmark statistics, 6 color themes, config management, environment variable tools, bookmark TAB completion, and much more!"
  s.authors     = ["Geir Isene"]
  s.email       = 'g@isene.com'
  s.files       = ["bin/rsh", "README.md", ".rshrc"]
  s.executables << 'rsh'
  s.homepage    = 'https://isene.com/'
  s.metadata    = { "source_code_uri" => "https://github.com/isene/rsh" }
end
