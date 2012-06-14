# -*- encoding: utf-8 -*-
require File.expand_path("../lib/active_record/migration_helper/version", __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Rob Hanlon']
  gem.email         = ['rob@mediapiston.com']
  gem.description   = 'Provides DSL methods to aid in zero-downtime migrations.'
  gem.summary       = gem.description
  gem.homepage      = 'http://github.com/ohwillie/activerecord_migration_helper'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "activerecord_migration_helper"
  gem.require_paths = ["lib"]
  gem.version       = ActiveRecord::MigrationHelper::VERSION

  gem.add_development_dependency 'rspec', '2.10.0'
  gem.add_development_dependency 'activerecord', '3.2.6'
  gem.add_development_dependency 'sqlite3', '1.3.6'

  gem.add_dependency 'rbx-require-relative', '0.0.9'
end
