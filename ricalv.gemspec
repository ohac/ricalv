# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ricalv}
  s.version = "0.1.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["OHASHI Hideya"]
  s.date = %q{2009-05-14}
  s.description = %q{iCalendar viewer for Ruby.}
  s.email = %q{ohachige@gmail.com}
  s.files = ["README", "lib/ricalv.rb", "bin/ricalv"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/ohac/ricalv}
  s.executables = ["ricalv"]
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{ricalv}
  s.rubygems_version = %q{1.3.2}
  s.summary = %q{iCalendar viewer for Ruby.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.3.2') then
      s.add_runtime_dependency(%q<icalendar>, [">= 1.1.0"])
    else
      s.add_dependency(%q<icalendar>, [">= 1.1.0"])
    end
  else
    s.add_dependency(%q<icalendar>, [">= 1.1.0"])
  end
end
