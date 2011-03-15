require "rubygems"
require "bundler"

Bundler.require

require "test/unit"
require "active_support/test_case"
require "faraday"

require 'omniauth-force'

Faraday.default_adapter = :test
