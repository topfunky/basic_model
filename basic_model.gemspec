Gem::Specification.new do |s|
  s.name = %q{BasicModel}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Geoffrey Grosenbach"]
  s.date = %q{2008-09-13}
  s.description = %q{A very thin wrapper around CouchRest, for use with CouchDB.}
  s.email = ["boss@topfunky.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "Manifest.txt", "README.txt", "Rakefile", "init.rb", "lib/basic_model.rb", "test/test_basic_model.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/topfunky/basic_model (url)}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{basicmodel}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{A very thin wrapper around CouchRest, for use with CouchDB.}
  s.test_files = ["test/test_basic_model.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_development_dependency(%q<hoe>, [">= 1.7.0"])
    else
      s.add_dependency(%q<hoe>, [">= 1.7.0"])
    end
  else
    s.add_dependency(%q<hoe>, [">= 1.7.0"])
  end
end
