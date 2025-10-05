Gem::Specification.new do |spec|
  spec.name          = "bootstrap5-rails-extensions"
  spec.version       = File.read(File.expand_path("lib/bootstrap5_rails_extensions/VERSION", __dir__)).strip
  spec.authors       = ["Dreaw Inc."]
  spec.email         = ["kodani@dreaw.jp"]

  spec.summary       = "Bootstrap 5 extensions for Rails (Stimulus/Turbo friendly)"
  spec.description   = "Rails Engine offering Bootstrap 5 extensions. Includes a render_modal helper and a shared modal partial, designed to work smoothly with Stimulus and Turbo."
  spec.homepage      = "https://dreaw.jp"
  spec.license       = "MIT"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir[
      "app/**/*",
      "lib/**/*",
      "README.md",
    ]
  end

  spec.add_dependency "rails", ">= 8.0"
end

