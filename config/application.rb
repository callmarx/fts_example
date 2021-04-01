# frozen_string_literal: true

require_relative 'boot'

require 'rails'
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_mailbox/engine'
require 'action_text/engine'
require 'action_view/railtie'
# require 'action_cable/engine'
# require 'sprockets/railtie'
# require 'rails/test_unit/railtie'

Bundler.require(*Rails.groups)

module FtsExample
  class Application < Rails::Application
    config.load_defaults 6.1
    config.time_zone = 'America/Sao_Paulo'
    config.api_only = true
    config.i18n.available_locales = ['pt-BR']
    config.i18n.default_locale = :'pt-BR'

    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end
  end
end
