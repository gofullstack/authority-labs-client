$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require "rubygems"
require "active_support"
require "active_resource"

# Mock expected AdWords object
module AdWords;module V13;module KeywordToolService 
  class SiteKeyword < Hash;end
end;end;end

module AuthorityLabs
  VERSION = '0.0.1'

  class ArgumentError < ArgumentError; end

  class Resource < ActiveResource::Base
    self.timeout = 5
  end

  class Domain < Resource
    self.element_name = "watched_domain"
  end

  class Keyword < Resource
    self.element_name = "watched_keyword"
  end

  class << self
    attr_accessor :api_key, :password, :subdomain

    # Set the options from an object
    def setup(options = {})
      options.symbolize_keys.each_pair do |k, v|
        self.send("#{k}=", v)
      end
      # Set the site for the ActiveResource objects
      Resource.site = Domain.site = site
      # Special for keywords
      Keyword.site = "#{site}watched_domains/:watched_domain_id"
      self
    end

    # Get the url used by the objects
    def site
      if [@api_key, @password, @subdomain].any? do |v| 
        v.nil? || !defined?(v)
      end
        raise AuthorityLabs::ArgumentError.new(
          "The API key, password, and subdomain must be defined."
        )
      else
        "http://#{@api_key}:#{@password}@#{@subdomain}.authoritylabs.com/"
      end
    end
  end
end
