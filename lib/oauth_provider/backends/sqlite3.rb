#raise "Sequel backend is incomplete"

#gem 'sqlite3-ruby'
require 'sqlite3'

module OAuthProvider
  module Stores
    class Sqlite3Store < OAuthProvider::Backends::Abstract
      def initialize(path)
        @db = SQLite3::Database.new(path)
        @db.execute("CREATE TABLE IF NOT EXISTS consumers (name CHAR(50), shared_key CHAR(32) PRIMARY KEY, secret_key CHAR(32), callback CHAR(255))")
        @db.execute("CREATE TABLE IF NOT EXISTS request_tokens (shared_key CHAR(16) PRIMARY KEY, secret_key CHAR(32), authorized INT, consumer_shared_key CHAR(32))")
        @db.execute("CREATE TABLE IF NOT EXISTS access_tokens (shared_key CHAR(16) PRIMARY KEY, secret_key CHAR(32), request_shared_key CHAR(32), consumer_shared_key CHAR(32))")
      end

      def create_consumer(consumer)
        @db.execute("INSERT INTO consumers (name, shared_key, secret_key, callback) " \
                    "VALUES ('#{consumer.name}', '#{consumer.shared_key}', '#{consumer.secret_key}', '#{consumer.callback}')")
      end

		def find_consumer(shared_key)
			@db.execute("SELECT name, callback, shared_key, secret_key FROM consumers WHERE shared_key='#{shared_key}' LIMIT 1") do |row|
				return OAuthProvider::Consumer.new(self, @provider, row[1], OAuthProvider::Token.new(row[2], row[3]))
			end
			nil
		end

		def destroy_consumer(consumer)
			@db.execute("DELETE FROM consumers WHERE shared_key='#{consumer.shared_key}' AND secret_key='#{consumer.secret_key}'")
		end

      def create_user_request(token)
        @db.execute("INSERT INTO request_tokens (shared_key, secret_key, authorized, consumer_shared_key) " \
                    "VALUES ('#{token.shared_key}','#{token.secret_key}',#{token.authorized? ? 1 : 0},'#{token.consumer.shared_key}')")
      end

      def find_user_request(shared_key)
        @db.execute("SELECT shared_key, secret_key, authorized, consumer_shared_key FROM request_tokens WHERE shared_key = '#{shared_key}' LIMIT 1") do |row|
          return OAuthProvider::UserRequest.new(self, self.find_consumer(row[3]), row[2].to_i!=0, OAuthProvider::Token.new(row[0], row[1]))
        end
        nil
      end

		def save_user_request(user_request)
			@db.execute("UPDATE request_tokens SET authorized=#{user_request.authorized? ? '1' : '0'} WHERE shared_key='#{user_request.shared_key}' AND secret_key='#{user_requent.secret_key}'")
		end

		def destroy_user_request(user_request)
			@db.execute("DELETE FROM request_tokens WHERE shared_key='#{user_request.shared_key}' AND secret_key='#{user_requent.secret_key}'")
		end

      def create_user_access(token)
        @db.execute("INSERT INTO access_tokens (shared_key, secret_key, consumer_shared_key, request_shared_key) " \
                    "VALUES ('#{token.shared_key}','#{token.secret_key}','#{token.consumer.shared_key}', '#{token.request_shared_key}')")
      end

      def find_user_access(shared_key)
        @db.execute("SELECT shared_key, secret_key, request_shared_key, consumer_shared_key FROM access_tokens WHERE shared_key = '#{shared_key}' LIMIT 1") do |row|
          return OAuthProvider::UserRequest.new(self, self.find_consumer(row[3]), true, OAuthProvider::Token.new(row[0], row[1]))
        end
        nil
      end
    end
  end
end
