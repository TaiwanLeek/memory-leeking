# frozen_string_literal: false

module SteamBuddy
  # Provides access to contributor data
  module Steam
    # Data Mapper: Steam contributor -> User entity
    class UserMapper
      def initialize(steam_key, gateway_class = Steam::Api)
        @key = steam_key
        @gateway_class = gateway_class
        @gateway = @gateway_class.new(@key)
      end

      def find(steam_id)
        friend_list_data = @gateway.friend_list_data(steam_id)
        build_entity(steam_id, friend_list_data)
      end

      def build_entity(steam_id, friend_list_data)
        DataMapper.new(steam_id, friend_list_data, @key, @gateway_class).build_entity
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(steam_id, friend_list_data, key, gateway_class)
          @steam_id = steam_id
          @friend_list_data = friend_list_data
          @played_game_mapper = PlayedGameMapper.new(
            key, gateway_class
          )
        end

        def build_entity
          SteamBuddy::Entity::User.new(
            steam_id: @steam_id,
            game_count:,
            played_games:,
            friend_list:
          )
        end

        private

        def game_count
          @played_game_mapper.find_game_count(@steam_id)
        end

        def played_games
          @played_game_mapper.find_games(@steam_id)
        end

        def friend_list
          @friend_list_data.map do |friend_data|
            friend_steam_id = friend_data['steamid']
            SteamBuddy::Entity::User.new(
              steam_id: friend_steam_id,
              game_count: nil,
              played_games: nil,
              friend_list: nil
            )
          end
        end
      end
    end
  end
end