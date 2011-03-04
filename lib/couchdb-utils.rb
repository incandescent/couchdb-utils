require "rubygems"

require 'base64'
require 'uuid'
require 'digest/sha1'
require 'json'
require 'uri'
require 'rest-client'

# couchdb utils for database provisioning  
module Couchdb
  class Utils
    def initialize(host, port, user = nil, pass = nil, protocol = 'http')
      if !user.nil? && !pass.nil?
        @uri = "#{protocol}://#{user}:#{pass}@#{host}:#{port}"
      else 
        @uri = "#{protocol}://#{host}:#{port}"
      end
      @headers = {:content_type => :json, :accept => :json}
    end

    # tests if user exists
    def user_exists?(username)
      #TODO
    end

    # creates all
    def create_all(username, password)
      resp1 = create_db(username)
      resp2 = create_user(username, password)
      resp3 = create_db_readers(username)
      yield resp1, resp2, resp3 if block_given?
    end

    # creates new database for given name
    def create_db(name)
      RestClient.put "#{@uri}/#{name}", '/', @headers
    end

    # create db readers
    # http://blog.couchone.com/post/1027100082/whats-new-in-couchdb-1-0-part-4-securityn-stuff
    def create_db_readers(name)
      readers = {:readers => {:names => ["#{name}"]}}
      RestClient.put "#{@uri}/#{name}/_security", 
        readers.to_json, @headers
    end

    # adds new user to _users table
    def create_user(username, password)
      user_doc = prepare_user_doc({:name => username}, password);
      RestClient.put "#{@uri}/_users/#{encode_doc_id(user_doc[:_id])}", 
        user_doc.to_json, @headers
    end

    #replicates document
    def replicate_doc(from_db, to_db, doc_id)
      replication = {:source => "#{@uri}/#{from_db}", :target => "#{@uri}/#{to_db}", :doc_ids => [doc_id]}
      RestClient.post "#{@uri}/_replicate", replication.to_json, @headers      
    end
    
    private
    
    # encodes uri
    def encode_uri(uri)
      URI.escape(uri, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
    end
    
    # encondes doc id
    def encode_doc_id(doc_id) 
      parts = doc_id.split("/")
      if parts[0] == "_design"
        parts.shift
        return "_design/" + encode_uri(parts.join('/'));
      end
      encode_uri(doc_id);
    end

    # prepares user document
    def prepare_user_doc(user_doc, user_password)
      user_doc[:_id] = "org.couchdb.user:" + user_doc[:name]
      if !user_password.nil? 
        user_doc[:salt] = UUID.generate
        user_doc[:password_sha] = Digest::SHA1.hexdigest(user_password + user_doc[:salt])
      end
      user_doc[:type] = "user"
      user_doc[:roles] = []
      return user_doc;
    end
  end
end
