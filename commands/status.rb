module Status
  # :reek:all
  STATUS = {
    waiting: 'waiting_for_registration',
    end: 'end_of_registration',
    pending_checkin_photo: 'pending_checkin_photo',
    pending_checkout_photo: 'pending_checkout_photo',
    registered: 'registered',
    pending_checkout_geolocation: 'pending_chekout_geolocation',
    pending_checkin_geolocation: 'pending_checkin_geolocation'
  }.freeze

  TYPE = {
    checkin: 'checkins',
    checkout: 'checkouts'
  }.freeze

  # :reek:all
  def set_new_status(status, options)
    options[:redis].set(options[:chat_id].to_s, status)
  end

  def current_status(options)
    options[:redis].get(options[:chat_id].to_s)
  end

  def developer_status(options)
    text = if options[:redis].get(options[:chat_id].to_s).nil?
             'not_registered'
           else
             options[:redis].get(options[:chat_id].to_s)
           end
    response_to_user(text, options)
  end
end
