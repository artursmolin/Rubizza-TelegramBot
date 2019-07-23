require 'telegram/bot'
require 'redis'
require 'down'
require 'fileutils'
require 'yaml'
require 'pry'
require 'open-uri'
require_relative 'commands/register.rb'
require_relative 'commands/start.rb'
require_relative 'commands/check.rb'
require_relative 'commands/geolocation.rb'
require_relative 'commands/photo.rb'
require_relative 'commands/status.rb'

class TelegramBot
  include Register
  include Status
  include Start
  include Check
  include Photo
  include Geolocation

  def parse_yaml
    YAML.load_file('users.yaml')
  end

  # :reek:all
  def run(token, redis)
    Telegram::Bot::Client.run(token) do |bot|
      bot.listen do |message|
        options = { bot: bot, redis: redis, message: message, chat_id: message.chat.id }
        users = parse_yaml
        flow(token, users, options)
      end
    end
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/PerceivedComplexity
  def flow(token, users, options)
    if options[:message].text.eql?('/start')
      start(options)
    elsif options[:message].text == '/checkin'
      checkin(options)
    elsif options[:message].text == '/checkout'
      checkout(options)
    elsif options[:message].text == '/developer/status'
      developer_status(options)
    elsif options[:message].text.to_i.positive?
      register_user(users, options)
    elsif options[:message].photo[1].methods.include?(:file_id)
      get_photo(token, options)
    elsif options[:message].location.nil? == false
      get_geolocation(options)
    elsif options[:message].text == '/commands'
      available_commands(options)
    else
      text = 'А мы можем нормально общаться?'
      response_to_user(text, options)
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/PerceivedComplexity

  def available_commands(options)
    commands = %w[/start /checkin /checkout]
    response_to_user(options, commands.to_s)
  end

  def response_to_user(text, options)
    options[:bot].api.send_message(chat_id: options[:chat_id],
                                   text: text)
  end
end

p 'Enter your TelegramBot token'
token = gets.chomp
redis = Redis.new

TelegramBot.new.run(token, redis)
