gem 'sqlite3-ruby'
require 'sqlite3'

module OAuthProvider
  module Backends
    class Sqlite3
      def initialize(path)
        @db = SQLite3::Database.new(path)
        @db.execute("CREATE TABLE IF NOT EXISTS consumers (name CHAR(50), shared_key CHAR(32) PRIMARY KEY, secret_key CHAR(32), callback CHAR(255))")
        @db.execute("CREATE TABLE IF NOT EXISTS request_tokens (shared_key CHAR(16) PRIMARY KEY, secret_key CHAR(32), authorized INT, consumer_shared_key CHAR(32))")
        @db.execute("CREATE TABLE IF NOT EXISTS access_tokens (shared_key CHAR(16) PRIMARY KEY, secret_key CHAR(32), request_shared_key CHAR(32), consumer_shared_key CHAR(32))")
      end

      def save_consumer(consumer)
        @db.execute("INSERT INTO consumers (name, shared_key, secret_key, callback) " \
                    "VALUES ('#{consumer.name}', '#{consumer.shared_key}', '#{consumer.secret_key}', '#{consumer.callback}')")
      end

      def fetch_consumer(shared_key)
        @db.execute("SELECT name, shared_key, secret_key, callback FROM consumers WHERE shared_key = '#{shared_key}' LIMIT 1") do |row|
          yield row[0], row[1], row[2], row[3]
        end
      end

      def save_request_token(token)
        @db.execute("INSERT INTO request_tokens (shared_key, secret_key, authorized, consumer_shared_key) " \
                    "VALUES ('#{token.shared_key}','#{token.secret_key}',#{token.authorized? ? 1 : 0},'#{token.consumer_shared_key}')")
      end

      def fetch_request_token(shared_key, consumer_shared_key)
        consumer_shared_key = "AND consumer_shared_key='#{consumer_shared_key}'" if consumer_shared_key
        @db.execute("SELECT shared_key, secret_key, authorized, consumer_shared_key FROM request_tokens WHERE shared_key = '#{shared_key}' #{consumer_shared_key} LIMIT 1") do |row|
          yield row[2], row[0], row[1]
        end
        nil
      end

      def authorize_request_token(token)
        @db.execute("UPDATE request_tokens SET authorized=1 WHERE shared_key='#{token.shared_key}'")
      end

      def save_access_token(token)
        @db.execute("INSERT INTO access_tokens (shared_key, secret_key, consumer_shared_key, request_shared_key) " \
                    "VALUES ('#{token.shared_key}','#{token.secret_key}','#{token.consumer_shared_key}', '#{token.request_shared_key}')")
      end

      def fetch_access_token(shared_key, consumer_shared_key)
        consumer_shared_key = "AND consumer_shared_key='#{consumer_shared_key}'" if consumer_shared_key
        @db.execute("SELECT shared_key, secret_key, request_shared_key, consumer_shared_key FROM access_tokens WHERE shared_key = '#{shared_key}' #{consumer_shared_key} LIMIT 1") do |row|
          consumer = fetch_consumer(row[3])
          return AccessToken.new(consumer, row[2], row[0], row[1])
        end
        nil
      end
    end
  end
end
