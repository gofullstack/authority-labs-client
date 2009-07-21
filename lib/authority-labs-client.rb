$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require "rubygems"
require "active_support"
require "active_resource"

module AuthorityLabs
  VERSION = '0.0.1'

  class ArgumentError < ArgumentError; end

  class Resource < ActiveResource::Base
    self.timeout = 5
  end

  class Keyword < Resource
    self.element_name = "watched_keyword"
  end

  class Domain < Resource
    self.element_name = "watched_domain"
  end

  class Client
    def initialize(options = {})
      options.symbolize_keys!

      # Throw error if arguments are incorrect
      valid_args = options.keys.include?(:api_key) &&
        options.keys.include?(:password)  &&
        options.keys.include?(:subdomain) &&
        options.values.compact.length >= 3

      unless valid_args
        raise ArgumentError.new 
          "The API key, password, and subdomain must be specified" 
      end

      @api_key = options[:api_key]
      @password = options[:password]
      @subdomain = options[:subdomain]
    end
    attr_accessor :api_key, :password, :subdomain

    def site
      "http://#{@api_key}:#{@password}@#{@subdomain}.authoritylabs.com/"
    end

    def domain
      Domain.site = site
      Domain
    end
    alias_method :domains, :domain

    def keyword_for(domain = nil)
      Keyword.site = site + "watched_domains/#{domain.id}/"
      Keyword
    end
    alias_method :keywords_for, :keyword_for
    alias_method :keyword, :keyword_for
    alias_method :keywords, :keyword_for
  end
end
