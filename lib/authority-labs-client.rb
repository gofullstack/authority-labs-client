$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require "rubygems"
require "restclient"
require "activesupport"

module AuthorityLabs
  VERSION = '0.0.1'

  # Error classes
  class ArgumentError < ArgumentError; end
  class ResponseError < StandardError; end
  class UnauthorizedError < RestClient::Unauthorized; end

  class Client
    EXPECTED_CONTENT_TYPE = "application/xml; charset=utf-8"

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

    def base_url
      "https://#{@api_key}:#{@password}@#{@subdomain}.authoritylabs.com/"
    end

    # Send requests through RestClient
    def method_missing(method_name, *args)
      if [:get, :post, :put, :delete].include?(method_name)
        args[0] = base_url + args[0].to_s # Add the base url to the url argument
        begin
          response = RestClient.send(method_name, *args)
          if response.headers[:content_type] != EXPECTED_CONTENT_TYPE 
            raise ResponseError.new
              "Did not get an XML response. Check your settings"
          end
        rescue RestClient::Unauthorized => e
          raise UnauthorizedError.new(e)
        end
      end
    end
  end

  class Domain
  end

  class Keyword
  end
end
