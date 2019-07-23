require_relative 'status.rb'

module Photo
  include Status

  # :reek:all
  def get_photo(token, options)
    case current_status(options)
    when STATUS[:pending_checkin_photo]
      checkin_photo(token, options)
    when STATUS[:pending_checkout_photo]
      checkout_photo(token, options)
    else
      response_to_user('А фотография где?', options)
    end
  end

  def checkin_photo(token, options)
    download_photo(TYPE[:checkin], token, options)
    set_new_status(STATUS[:pending_checkin_geolocation], options)
  end

  def checkout_photo(token, options)
    download_photo(TYPE[:checkout], token, options)
    set_new_status(STATUS[:pending_checkout_geolocation], options)
  end

  # rubocop: disable Metrics/AbcSize
  # rubocop: disable Metrics/LineLength
  def download_photo(type, token, options)
    file_path = options[:bot].api.get_file(file_id: options[:message].photo[1].file_id)
    uri = 'https://api.telegram.org/file/bot' + token + '/' + file_path['result']['file_path']
    Down.download(uri, destination:
                  "users/#{type}/#{options[:redis].get('user_id')}/#{options[:redis].get('timestamp')}/")
    response_to_user('Теперь геолокация!', options)
  end
  # rubocop: enable Metrics/AbcSize
  # rubocop: enable Metrics/LineLength
end
