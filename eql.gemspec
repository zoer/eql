lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'eql/version'

Gem::Specification.new do |spec|
  spec.name          = 'eql'
  spec.version       = Eql::VERSION
  spec.authors       = ['Oleg Yashchuk']
  spec.email         = ['oazoer@gmail.com']

  spec.summary       = 'Eql Query Language'
  spec.description   = 'Eql provides an ability to use ERB templates with your DB queries'
  spec.license       = 'MIT'

  spec.files         = Dir.glob("{lib}/**/*") + %w[LICENSE.txt README.md]
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'rspec', '~> 3.5'
  spec.add_development_dependency 'activerecord'
  spec.add_development_dependency 'sqlite3'
end
