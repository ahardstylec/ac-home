module ApplicationHelper
  # def pat(what)
  #   t(what)
  # end

  def icon_tag(icon, text="", classes=[])
    "<i class='fa fa-#{icon} #{classes.map{|c| "fa-#{c}"}.join(" ")}'>#{text}</i>".html_safe
  end

  def icon_tag_me(icon, text="", classes=[])
    debugger if icon == 'sign-out'
    "<i class='fa fa-#{icon} #{classes.map{|c| "fa-#{c}"}.join(" ")}'>#{text}</i>".html_safe
  end

  # def send_data(data, filename, content_type=nil)
  #   # response.headers['Content-Type']=content_type || 'application/octet-stream'
  #   # attachment(File.basename(filename))
  #   # response.write(data)
  # end
end
