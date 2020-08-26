require File.expand_path('../lib/storyblok/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'storyblok'
  gem.version       = Storyblok::VERSION
  gem.summary       = 'storyblok'
  gem.description   = 'Ruby client for the https://www.storyblok.com management and content delivery API'
  gem.license       = 'MIT'
  gem.authors       = ['Storyblok (Alexander Feiglstorfer)']
  gem.email         = 'it@storyblok.com'
  gem.homepage      = 'https://github.com/storyblok/storyblok-ruby'

  gem.files         = Dir['{**/}{.*,*}'].select { |path| File.file?(path) && !path.start_with?('pkg') && !path.end_with?('.gem') }
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^spec/})
  gem.require_paths = ['lib']

  gem.add_dependency 'rest-client', '>= 1.8.0', '< 3'
  gem.add_dependency 'storyblok-richtext-renderer', '>= 0.0.4', '< 1'

  gem.add_development_dependency 'bundler', '~> 1.5'
  gem.add_development_dependency 'rspec', '~> 3'
  gem.add_development_dependency 'webmock'
  gem.add_development_dependency 'vcr'
  gem.add_development_dependency 'simplecov', '~> 0.17.0'
end
