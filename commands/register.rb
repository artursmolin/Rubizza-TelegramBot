require_relative 'status.rb'

module Register
  include Status

  # :reek:all
  def register_user(users, options)
    user_validation(users, options) if current_status(options) == STATUS[:waiting]
  end

  def user_validation(users, options)
    if users['id'].include?(options[:message].text.to_i)
      options[:redis].set('user_id', options[:message].text.to_i)
      create_user_folder(options)
      set_new_status(STATUS[:pending_checkin_photo], options)
    else
      response_to_user('Ты нас обмамнул. Ты не с нами', options)
    end
  end

  def create_user_folder(options)
    FileUtils.mkdir_p "users/checkins/#{options[:redis].get('user_id')}"
    FileUtils.mkdir_p "users/checkouts/#{options[:redis].get('user_id')}"
    response_to_user('Вводи /checkin и погнали отмечаться!', options)
  end
end
