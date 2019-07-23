require_relative 'status.rb'

module Geolocation
  include Status

  RUBIZZA = { latitude: 59, longitude: 30 }.freeze

  # :reek:all
  def get_geolocation(options)
    case current_status(options)
    when STATUS[:pending_checkin_geolocation]
      load_checkin_geo(options)
    when STATUS[:pending_checkout_geolocation]
      load_checkout_geo(options)
    end
  end

  def load_checkin_geo(options)
    if geo_validation(options)
      save_geo_to_file(TYPE[:checkin], options)
      response_to_user('Отлично, порви сегодня всех. За себя и за Сашку.', options)
      set_new_status(STATUS[:registered], options)
    else
      response_to_user('БЕГОМ В КЭМП!', options)
    end
  end

  def load_checkout_geo(options)
    if geo_validation(options)
      save_geo_to_file(TYPE[:checkout], options)
      response_to_user('Ты был молодцом, солдат!', options)
      set_new_status(STATUS[:end], options)
    else
      response_to_user('БЕГОМ В КЭМП!', options)
    end
  end

  # rubocop: disable Metrics/AbcSize
  # rubocop: disable Metrics/LineLength
  def save_geo_to_file(type, options)
    location = options[:message].location.latitude.to_s + ',' +
               options[:message].location.longitude.to_s
    File.write("users/#{type}/#{options[:redis].get('user_id')}/#{options[:redis].get('timestamp')}/geo.txt",
               location)
  end
  # rubocop: enable Metrics/AbcSize
  # rubocop: enable Metrics/LineLength

  def geo_validation(options)
    options[:message].location.latitude.to_i == RUBIZZA[:latitude] &&
      options[:message].location.longitude.to_i == RUBIZZA[:longitude]
  end
end
