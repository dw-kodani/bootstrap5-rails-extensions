# frozen_string_literal: true

require_relative "lib/bootstrap5_rails_extensions/version"

Gem::Specification.new do |spec|
  spec.name = "bootstrap5-rails-extensions"
  spec.version = Bootstrap5RailsExtensions::VERSION
  spec.authors = ["Dreaw Inc."]
  spec.email = ["kodani@dreaw.jp"]

  spec.summary = "Bootstrap 5 extensions for Rails (Stimulus/Turbo friendly)"
  spec.description = "Rails Engine offering Bootstrap 5 extensions. Includes a render_modal helper and a shared modal partial, designed to work smoothly with Stimulus and Turbo."
  spec.homepage = "https://github.com/dw-kodani/bootstrap5-rails-extensions"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["rubygems_mfa_required"] = "true"

  tracked_files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true)
  end

  spec.files = if tracked_files&.any?
                 tracked_files.reject do |path|
                   path.start_with?("AGENTS.md", "CLAUDE.md", "pkg/")
                 end.select do |path|
                   File.file?(File.expand_path(path, __dir__))
                 end
               else
                 Dir.chdir(__dir__) do
                   Dir[
                     "{app,config,lib,bin}/**/*",
                     "README.md",
                     "LICENSE.txt",
                     "Rakefile",
                     "Gemfile"
                   ].select { |path| File.file?(path) }
                 end
               end

  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 8.0"
end
