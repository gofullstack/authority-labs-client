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

    # If the resource can't be found, return nil instead of an error
    def self.find(*arguments)
      begin
        super(*arguments)
      rescue ActiveResource::ResourceNotFound => e
        nil
      end
    end
    
    # This here is a hack to remove the nested root node from the request. Sets
    # the root node to nil and removes the <> and </>
    def encode(options={})
      self.class.format.encode(attributes, {:root => nil}.merge(options)).gsub(
        /<\/?>/, "")
    end
  end

  class Keyword < Resource
    self.element_name = "watched_keyword"

    # The keywords can return multiple records on a single find, which will
    # make AR freak, so we have to patch that here.
    #
    # This method also sets the id of the record to be the watched keyword
    # id for which we can do a find and reference later
    def load(attributes)
      if attributes.is_a?(Array)
        records = attributes.clone
        attributes = {}
        id = nil
        if records.length >= 1
          records.each_with_index do |rec, i|
            # The "actual" id is the 1st
            id = rec["id"] if i == 0 && rec["id"].to_i > 0
            attributes.merge!(rec)
          end
          attributes["id"] = id || attributes["id"]
        end
      end
      super(attributes)
    end
  end

  class Domain < Resource
    self.element_name = "watched_domain"

    # Array of all keywords for domain
    def keywords
      @keywords ||= keyword_class.find(:all, :params => { 
        :watched_domain_id => self.id })
    end

    # Add a keyword
    def create_keyword(keywords = "")
      keyword_class.create(:keyword_name => keywords, 
                           :watched_domain_id => self.id)
    end

    # Find a keyword by id
    def find_keyword(keyword_id = 0)
      keyword_class.find(keyword_id, :params => {:watched_domain_id => self.id})
    end

    private
      def keyword_class
        AuthorityLabs::Keyword
      end
  end

  class << self
    attr_accessor :api_key, :password, :subdomain

    # Set the options from an object
    def setup(options = {})
      options.symbolize_keys.each_pair do |k, v|
        self.send("#{k}=", v)
      end
      # Set the site for the ActiveResource objects
      Resource.site = site
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
