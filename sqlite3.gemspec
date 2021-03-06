# -*- coding: utf-8 -*-

lib = File.expand_path("../lib/", __FILE__)
$:.unshift(lib) unless $:.include?(lib)

require "sqlite3/version"

Gem::Specification.new do |s|
  s.name = "sqlite3"
  s.version = SQLite3::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Jakub Kuźma"]
  s.email = "qoobaa@gmail.com"
  s.homepage = "http://github.com/qoobaa/sqlite3"
  s.summary = "SQLite3 FFI bindings for Ruby 1.9"
  s.description = "Experimental SQLite3 FFI bindings for Ruby 1.9 with encoding support"

  s.required_rubygems_version = ">= 1.3.6"

  s.add_dependency "ffi", ">= 0.6.3"
  s.add_development_dependency "rspec", ">= 2.4.0"
  s.add_development_dependency "activerecord", ">= 3.0.0"
  s.add_development_dependency "activesupport", ">= 3.0.0"

  s.files = Dir.glob("{lib}/**/*") + %w(LICENSE README.rdoc)

  s.post_install_message = <<-EOM
==== WARNING ===================================================================
This is an early alpha version of SQLite3/Ruby FFI bindings!

If you need native bindings for Ruby 1.8/1.9 - install sqlite3-ruby
instead.  You may need to uninstall this sqlite3 gem as well.

Thank you for installing sqlite3 gem! Suggestions: qoobaa@gmail.com
================================================================================
EOM
end
