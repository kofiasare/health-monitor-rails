module Monitoring
  class Configuration
    PROVIDERS = %i[cache database delayed_job redis resque sidekiq].freeze

    attr_accessor :error_callback, :basic_auth_credentials, :environment_variables, :customize
    attr_reader   :providers

    def initialize
      database
    end

    def no_database
      @providers.delete(Monitoring::Providers::Database)
    end

    PROVIDERS.each do |provider_name|
      define_method provider_name do |&_block|
        require "monitoring/providers/#{provider_name}"
        add_provider("Monitoring::Providers::#{provider_name.to_s.titleize.delete(' ')}".constantize)
      end
    end

    def add_custom_provider(custom_provider_class)
      unless custom_provider_class < Monitoring::Providers::Base
        raise ArgumentError.new 'custom provider class must implement '\
          'Monitoring::Providers::Base'
      end

      add_provider(custom_provider_class)
    end

    private

    def add_provider(provider_class)
      (@providers ||= Set.new) << provider_class
      provider_class
    end
  end
end
