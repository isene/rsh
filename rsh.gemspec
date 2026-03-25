version = File.read(File.join(__dir__, 'bin/rsh'))[/@version\s*=\s*"([^"]+)"/, 1]
Gem::Specification.new do |s|
  s.name        = 'ruby-shell'
  s.version     = version
  s.licenses    = ['Unlicense']
  s.summary     = "rsh - Ruby SHell"
  s.description = "A shell written in Ruby with extensive tab completions, aliases/nicks, history, syntax highlighting, theming, auto-cd, auto-opening files and more. UPDATE v3.6.18: Fix nick deletion persistence and hyphenated command substitution."
  s.authors     = ["Geir Isene"]
  s.email       = 'g@isene.com'
  s.files       = ["bin/rsh", "README.md", "PLUGIN_GUIDE.md", ".rshrc"]
  s.executables << 'rsh'
  s.homepage    = 'https://isene.com/'
  s.metadata    = { "source_code_uri" => "https://github.com/isene/rsh" }
end
