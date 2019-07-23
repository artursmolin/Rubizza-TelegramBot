require_relative 'status.rb'

module Check
  include Status

  # :reek:all
  def checkin(options)
    end?(options)
    options[:redis].set('timestamp', Time.now.to_s)
    case current_status(options)
    when STATUS[:pending_checkin_photo]
      create_directory(TYPE[:checkin], options)
      response_to_user('Пришли мне себяшку!', options)
    when STATUS[:registered]
      response_to_user('Может ты хотел написать /checkout ?', options)
    end
  end

  def checkout(options)
    options[:redis].set('timestamp', Time.now.to_s)
    case current_status(options)
    when STATUS[:registered]
      create_directory(TYPE[:checkout], options)
      response_to_user('Пришли мне себяшку!', options)
      set_new_status(STATUS[:pending_checkout_photo], options)
    when STATUS[:end]
      response_to_user('Может быть /checkin принцесса?', options)
    end
  end

  def create_directory(type, options)
    FileUtils.mkdir_p "users/#{type}/#{options[:redis].get('user_id')}/" +
                      options[:redis].get('timestamp')
  end

  def end?(options)
    set_new_status(STATUS[:pending_checkin_photo], options) unless
    current_status(options).eql?(STATUS[:end])
  end
end
