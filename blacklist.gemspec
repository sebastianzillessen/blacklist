Gem::Specification.new do |s|
  s.name     = "blacklist"
  s.version  = "1.0.0"
  s.date     = "2008-11-08"
  s.summary  = "A simple content filtering system"
  s.email    = "github@watsonian.otherinbox.com"
  s.homepage = "http://github.com/watsonian/blacklist"
  s.description = "BlackList is a Ruby library offering simple content filtering via blacklisted words."
  s.has_rdoc = true
  s.authors  = ["Joel Watson"]
  s.files    = ["README.textile", 
    "lib/black_list.rb", 
    "config/black_list.yml"]
  s.test_files = ["spec/black_list_spec.rb"]
  s.add_dependency("RedCloth", ["> 0.0.0"])
end