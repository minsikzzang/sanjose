require "bundler/gem_tasks"
Bundler.setup

gemspec = eval(File.read("sanjose.gemspec"))

task :build => "#{gemspec.full_name}.gem"

file "#{gemspec.full_name}.gem" => gemspec.files + ["sanjose.gemspec"] do
  system "gem build houston.gemspec"
  system "gem install sanjose-#{Houston::VERSION}.gem"
end