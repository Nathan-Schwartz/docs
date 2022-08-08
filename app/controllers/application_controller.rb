class ApplicationController < ActionController::Base
  helper_method :probably_authenticated?

  def route_not_found
    render file: Rails.root.join("public","404.html"), layout: false, status: 404
  end

  private

  def fetch_local_data(name)
    file_path = File.join(Rails.root, 'data', "#{name}.yml")
    YAML.load_file(file_path) || []
  end

  def get_nav_data(name = 'nav')
    Nav.new(fetch_local_data(name)).nav_tree
  end
  helper_method :get_nav_data

  def notification_data
    Notification.new(fetch_local_data('notification')).message || []
  end
  helper_method :notification_data

  # capture some extra data so we can log it with lograge
  def append_info_to_payload(payload)
    super

    # Use the request ID generated by the aamzon ALB, if available
    payload[:request_id] = request.headers.fetch("X-Amzn-Trace-Id", request.request_id)
    payload[:remote_ip] = request.remote_ip
    payload[:user_agent] = request.user_agent
  end


  # When you login to Buildkite, we set this cookie as an indicator for other
  # services that the user *may* be logged in.
  def probably_authenticated?
    request.cookie_jar[:bk_logged_in] == "true"
  end
end
