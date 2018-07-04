module Monitoring
  class StatusController < ActionController::Base
    protect_from_forgery with: :exception
    Rails.version.starts_with?('3') ? before_filter(:authenticate_with_basic_auth) : 
                                      before_action(:authenticate_with_basic_auth)

    def status
      @customize = Monitoring.configuration.customize || { title: "Monitoring Rails", footer: 'Monitoring Rails'}
      @statuses = statuses
      respond_to do |f|
        f.html
        f.json { render json: statuses.to_json, status: statuses[:status] }
        f.xml  { render xml: statuses.to_xml,   status: statuses[:status] }
      end
    end

    private

    def statuses
      res = Monitoring.check(request: request)
      res.merge(env_vars)
    end

    def env_vars
      v = Monitoring.configuration.environment_variables || {}
      v.empty? ? {} : { environment_variables: v }
    end

    def authenticate_with_basic_auth
      return true unless Monitoring.configuration.basic_auth_credentials
      credentials = Monitoring.configuration.basic_auth_credentials
      authenticate_or_request_with_http_basic do |name, password|
        name == credentials[:username] && password == credentials[:password]
      end
    end

  end
end
