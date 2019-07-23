require_relative 'status.rb'

module Start
  include Status

  # :reek:all
  def start(options)
    case current_status(options)
    when STATUS[:end].inspect
      set_new_status(STATUS[:pending_checkin_photo], options)
      response_to_user('Вводи /checkin и погнали отмечаться!', options)
    when nil
      set_new_status(STATUS[:waiting], options)
      response_to_user('Введи свой порядковый номер!', options)
    else
      response_to_user('Ошибочка вышла! Попробуй снова', options)
    end
  end
end
