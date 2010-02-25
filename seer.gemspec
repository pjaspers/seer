# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{seer}
  s.version = "0.4.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Corey Ehmke / SEO Logic"]
  s.date = %q{2010-02-25}
  s.description = %q{ Seer is a lightweight, semantically rich wrapper for the Google Visualization API. It allows you to easily create a visualization of data in a variety of formats, including area charts, bar charts, column charts, gauges, line charts, and pie charts.}
  s.email = %q{corey@seologic.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    "LICENSE",
     "README.rdoc",
     "Rakefile",
     "init.rb",
     "lib/seer.rb",
     "lib/seer/annotated_time_line_chart.rb",
     "lib/seer/area_chart.rb",
     "lib/seer/bar_chart.rb",
     "lib/seer/chart.rb",
     "lib/seer/column_chart.rb",
     "lib/seer/gauge.rb",
     "lib/seer/line_chart.rb",
     "lib/seer/pie_chart.rb",
     "spec/seer_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/Bantik/seer}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Seer is a lightweight, semantically rich wrapper for the Google Visualization API.}
  s.test_files = [
    "spec/area_chart_spec.rb",
     "spec/bar_chart_spec.rb",
     "spec/chart_spec.rb",
     "spec/column_chart_spec.rb",
     "spec/gauge_spec.rb",
     "spec/line_chart_spec.rb",
     "spec/pie_chart_spec.rb",
     "spec/seer_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
    else
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
  end
end

