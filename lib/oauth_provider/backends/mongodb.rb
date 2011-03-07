# Warning - I am a major MongoDB n00b. If you know more about MongoDB than
# I do please fork-and-fix. -Ikai Lan
# I've tested this and it works.
begin
  require 'mongo'
rescue LoadError
  require 'rubygems'
  require 'mongo'
end

module OAuthProvider
  module Backends
    class Mongodb < OAuthProvider::Backends::Abstract
      def initialize(host="127.0.0.1", port=27017, db='oauth')
        @db = Mongo::Connection.new(host, port).db(db)
        @consumers = @db.collection("consumers")
        @request_tokens = @db.collection("request_tokens")
        @access_tokens = @db.collection("access_tokens")
      end
		attr_reader :db

      def clear!
        @consumers.remove
        @request_tokens.remove
        @access_tokens.remove
      end

      def create_consumer(consumer)
        # Possible race condition, WAH WAH, this is copied from the
        # MySQL library.
        existing_consumer = @consumers.find_one({"callback" => consumer.callback})
        if !existing_consumer.nil?
          raise OAuthProvider::DuplicateCallback.new(consumer)
        end
        new_consumer = {
            "name" => '', 
            "shared_key" => consumer.shared_key,
            "secret_key" => consumer.secret_key,
            "callback" => consumer.callback 
        }
        @consumers.insert(new_consumer, :safe => true)
      end

      def find_consumer(shared_key)
        consumer = @consumers.find_one({"shared_key" => shared_key})
        if consumer
            return OAuthProvider::Consumer.new(self, 
                @provider, 
                consumer["callback"],
                OAuthProvider::Token.new(
                    consumer["shared_key"], consumer["secret_key"]))
        end
        nil
      end

      def consumers
        rtrn = []
        @consumers.find.each do |consumer|
            rtrn << OAuthProvider::Consumer.new(self, 
                    @provider, 
                    consumer["callback"],
                    OAuthProvider::Token.new(
                        consumer["shared_key"], consumer["secret_key"]))
        end
        rtrn
      end

      def destroy_consumer(consumer)
        @consumers.remove({"shared_key" => consumer.shared_key})
      end

      def create_user_request(token)
        request_token = {
            "shared_key" => token.shared_key,
            "secret_key" => token.secret_key,
            "authorized" => token.authorized?,
            "consumer_shared_key" => token.consumer.shared_key
        }
        @request_tokens.insert(request_token, :safe => true)
      end

      def find_user_request(shared_key)
        request_token = @request_tokens.find_one({"shared_key" => shared_key})
        if request_token
            return OAuthProvider::UserRequest.new(self, 
                self.find_consumer(request_token["consumer_shared_key"]),
                request_token["authorized"],
                OAuthProvider::Token.new(
                    request_token["shared_key"], request_token["secret_key"]))
        end
        raise OAuthProvider::UserRequestNotFound.new(shared_key)
      end

      def save_user_request(user_request)
        request_token = @request_tokens.find_one(
            {"shared_key" => user_request.shared_key, 
             "secret_key" => user_request.secret_key})
        request_token["authorized"] = user_request.authorized?
        @request_tokens.save(request_token, :safe => true)
      end

      def destroy_user_request(user_request)
        @request_tokens.remove({"shared_key" => user_request.shared_key, 
            "secret_key" => user_request.secret_key})
      end

      def create_user_access(token)
        access_token = {
            "shared_key" => token.shared_key,
            "secret_key" => token.secret_key,
            "consumer_shared_key" => token.consumer.shared_key,
            "request_shared_key" => token.request_shared_key
        }
        @access_tokens.insert(access_token, :safe => true)
      end

      def find_user_access(shared_key)
        access_token = @access_tokens.find_one({"shared_key" => shared_key})
        return OAuthProvider::UserAccess.new(self, 
            self.find_consumer(access_token["consumer_shared_key"]), 
            access_token["request_shared_key"],
            OAuthProvider::Token.new(access_token["shared_key"], 
                access_token["secret_key"]))
        nil
      end

    end
  end
end
