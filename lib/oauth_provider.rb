require 'rubygems'
gem 'oauth'

require 'oauth'
require 'oauth/server'
require 'oauth/signature'

module OAuthProvider
  def self.new(*args)
    Provider.new(*args)
  end
end

$:.unshift File.dirname(__FILE__)

require 'oauth_provider/fixes'
require 'oauth_provider/provider'
require 'oauth_provider/backends'
require 'oauth_provider/backends/abstract'
require 'oauth_provider/token'
require 'oauth_provider/consumer'
