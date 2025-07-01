Gem::Specification.new do |s|
  s.name        = 'ruby-shell'
  s.version     = '2.7.0'
  s.licenses    = ['Unlicense']
  s.summary     = "rsh - Ruby SHell"
  s.description = "A shell written in Ruby with extensive tab completions, aliases/nicks, history, syntax highlighting, theming, auto-cd, auto-opening files and more. MAJOR UPDATE v2.7.0: Ruby Functions - define custom shell commands using full Ruby power! Also: job control (background jobs, Ctrl-Z suspension), command substitution, variable expansion, conditional execution, login shell support, and much more."
  s.authors     = ["Geir Isene"]
  s.email       = 'g@isene.com'
  s.files       = ["bin/rsh", "README.md", ".rshrc"]
  s.executables << 'rsh'
  s.homepage    = 'https://isene.com/'
  s.metadata    = { "source_code_uri" => "https://github.com/isene/rsh" }
end
