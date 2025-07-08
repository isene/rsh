Gem::Specification.new do |s|
  s.name        = 'ruby-shell'
  s.version     = '2.8.0'
  s.licenses    = ['Unlicense']
  s.summary     = "rsh - Ruby SHell"
  s.description = "A shell written in Ruby with extensive tab completions, aliases/nicks, history, syntax highlighting, theming, auto-cd, auto-opening files and more. UPDATE v2.8.0: Enhanced help system with two-column display, new :info command, :nickdel/:gnickdel commands for easier nick management. v2.7.0: Ruby Functions - define custom shell commands using full Ruby power! Also: job control, command substitution, variable expansion, conditional execution, and login shell support."
  s.authors     = ["Geir Isene"]
  s.email       = 'g@isene.com'
  s.files       = ["bin/rsh", "README.md", ".rshrc"]
  s.executables << 'rsh'
  s.homepage    = 'https://isene.com/'
  s.metadata    = { "source_code_uri" => "https://github.com/isene/rsh" }
end
