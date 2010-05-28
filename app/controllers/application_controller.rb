class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'

#  rescue_from CanCan::AccessDenied do |exception|
#    flash[:error] = "Access denied."
#    redirect_to root_url
#  end

  def render_json_response(type, hash={})
    unless [ :ok, :redirect, :error ].include?(type)
      raise "Invalid json response type: #{type}"
    end

    default_json_structure = {
      :status => type,
      :html => nil,
      :message => nil,
      :to => nil }.merge(hash)

    render_options = {:json => default_json_structure}
    render_options[:status] = 400 if type == :error

    render(render_options)
  end

end
