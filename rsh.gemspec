Gem::Specification.new do |s|
  s.name        = 'ruby-shell'
  s.version     = '3.5.0'
  s.licenses    = ['Unlicense']
  s.summary     = "rsh - Ruby SHell"
  s.description = "A shell written in Ruby with extensive tab completions, aliases/nicks, history, syntax highlighting, theming, auto-cd, auto-opening files and more. UPDATE v3.5.0: Nick/history export, 9 new tool completions (kubectl, terraform, aws, brew, etc.), validation templates, startup tips, improved :info, aggressive suggest_command optimization for huge PATHs (18K+ executables), timestamp shows corrected commands!"
  s.authors     = ["Geir Isene"]
  s.email       = 'g@isene.com'
  s.files       = ["bin/rsh", "README.md", "PLUGIN_GUIDE.md", ".rshrc"]
  s.executables << 'rsh'
  s.homepage    = 'https://isene.com/'
  s.metadata    = { "source_code_uri" => "https://github.com/isene/rsh" }
end
