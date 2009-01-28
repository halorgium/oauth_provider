begin
	require 'mysql'
rescue LoadError
	require 'rubygems'
	require 'mysql'
end

module OAuthProvider
  module Backends
    class Mysql < OAuthProvider::Backends::Abstract
      def initialize(host, user, password, db, port=nil)
        @db = ::Mysql::real_connect(host, user, password, db, port)
		  @db.reconnect = true
		  @db.real_query("SET NAMES 'UTF8'")
		  # FIXME: The key column widths are perhaps not right. What is the max width of each?
        @db.real_query("CREATE TABLE IF NOT EXISTS consumers (name CHAR(50), shared_key CHAR(43) PRIMARY KEY, secret_key CHAR(43), callback CHAR(255))")
        @db.real_query("CREATE TABLE IF NOT EXISTS request_tokens (shared_key CHAR(22) PRIMARY KEY, secret_key CHAR(43), authorized INT, consumer_shared_key CHAR(43))")
        @db.real_query("CREATE TABLE IF NOT EXISTS access_tokens (shared_key CHAR(22) PRIMARY KEY, secret_key CHAR(43), request_shared_key CHAR(43), consumer_shared_key CHAR(43))")
      end

		def clear!
        @db.real_query("DROP TABLE IF EXISTS consumers")
        @db.real_query("DROP TABLE IF EXISTS request_tokens")
        @db.real_query("DROP TABLE IF EXISTS access_tokens")
		end

      def create_consumer(consumer)
			# XXX: Should come up with a better way to store names than forcing the gem user to hack it in manually.
			# Also, OAuthProvider::DuplicateCallback is a bit silly... multiple consumers with the same callback may be useful (especially since callbacks are optional.
			@db.query("SELECT callback FROM consumers WHERE callback='#{consumer.callback}' LIMIT 1").each do
				raise OAuthProvider::DuplicateCallback.new(consumer)
			end
			@db.real_query("INSERT INTO consumers (name, shared_key, secret_key, callback) " \
			            "VALUES ('', '#{consumer.shared_key}', '#{consumer.secret_key}', '#{consumer.callback}')")
      end

		def find_consumer(shared_key)
			@db.query("SELECT name, callback, shared_key, secret_key FROM consumers WHERE shared_key='#{shared_key}' LIMIT 1").each do |row|
				return OAuthProvider::Consumer.new(self, @provider, row[1], OAuthProvider::Token.new(row[2], row[3]))
			end
			nil
		end

		def consumers
			rtrn = []
			@db.query("SELECT name, callback, shared_key, secret_key FROM consumers").each do |row|
				rtrn << OAuthProvider::Consumer.new(self, @provider, row[1], OAuthProvider::Token.new(row[2], row[3]))
			end
			rtrn
		end

		def destroy_consumer(consumer)
			@db.real_query("DELETE FROM consumers WHERE shared_key='#{consumer.shared_key}' AND secret_key='#{consumer.secret_key}'")
		end

      def create_user_request(token)
        @db.real_query("INSERT INTO request_tokens (shared_key, secret_key, authorized, consumer_shared_key) " \
                    "VALUES ('#{token.shared_key}','#{token.secret_key}',#{token.authorized? ? 1 : 0},'#{token.consumer.shared_key}')")
      end

      def find_user_request(shared_key)
        @db.query("SELECT shared_key, secret_key, authorized, consumer_shared_key FROM request_tokens WHERE shared_key = '#{shared_key}' LIMIT 1").each do |row|
          return OAuthProvider::UserRequest.new(self, self.find_consumer(row[3]), row[2].to_i!=0, OAuthProvider::Token.new(row[0], row[1]))
        end
		  raise OAuthProvider::UserRequestNotFound.new(shared_key)
        nil
      end

		def save_user_request(user_request)
			@db.real_query("UPDATE request_tokens SET authorized=#{user_request.authorized? ? '1' : '0'} WHERE shared_key='#{user_request.shared_key}' AND secret_key='#{user_request.secret_key}'")
		end

		def destroy_user_request(user_request)
			@db.real_query("DELETE FROM request_tokens WHERE shared_key='#{user_request.shared_key}' AND secret_key='#{user_request.secret_key}'")
		end

      def create_user_access(token)
        @db.real_query("INSERT INTO access_tokens (shared_key, secret_key, consumer_shared_key, request_shared_key) " \
                    "VALUES ('#{token.shared_key}','#{token.secret_key}','#{token.consumer.shared_key}', '#{token.request_shared_key}')")
      end

      def find_user_access(shared_key)
        @db.query("SELECT shared_key, secret_key, request_shared_key, consumer_shared_key FROM access_tokens WHERE shared_key = '#{shared_key}' LIMIT 1").each do |row|
          return OAuthProvider::UserRequest.new(self, self.find_consumer(row[3]), true, OAuthProvider::Token.new(row[0], row[1]))
        end
        nil
      end
    end
  end
end
