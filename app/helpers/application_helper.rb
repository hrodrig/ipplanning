module ApplicationHelper

  def get_icon(status)
    if status == true
      image_tag 'on.png'
    else
      image_tag 'off.png'
    end
  end

end
