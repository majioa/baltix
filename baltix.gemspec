require_relative 'lib/baltix/version'

Gem::Specification.new do |spec|
   spec.name          = "baltix"
   spec.version       = Baltix::VERSION
   spec.authors       = ["Pavel Skrylev"]
   spec.email         = ["majioa@altlinux.org"]
   spec.licenses      = ["MIT"]

   spec.summary       = %q{Baltix is setup replacement and spec control utility for RPM/local packages}
   spec.description   = %q{Baltix is setup replacement and spec control utility for RPM/local packages}
   spec.homepage      = "https://github.org/majioa/baltix"
   spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

   spec.metadata["allowed_push_host"] = "https://rubygems.org"

   spec.metadata["homepage_uri"] = spec.homepage
   spec.metadata["source_code_uri"] = "https://github.org/majioa/baltix"
   spec.metadata["changelog_uri"] = "https://github.org/majioa/baltix/CHANGELOG.md"

   # Specify which files should be added to the gem when it is released.
   # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
   spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
     `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
   end
   spec.bindir        = "exe"
   spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
   spec.require_paths = ["lib"]

   spec.required_ruby_version = [ '>= 3.0.0' ]
   spec.add_development_dependency "bundler", "~> 2.0"
   spec.add_development_dependency "rake", ">= 12.0"
   spec.add_development_dependency "pry", "~> 0.13"
   spec.add_development_dependency "cucumber", "~> 5.2"
   spec.add_development_dependency "shoulda-matchers-cucumber", "~> 1.0", ">= 1.0.1"
   spec.add_development_dependency "timecop"
   spec.add_development_dependency "simplecov"
   spec.add_development_dependency "simplecov-lcov"
end
