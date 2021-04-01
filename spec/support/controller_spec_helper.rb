# frozen_string_literal: true

module ControllerSpecHelper
  def request_json
    before { request.env['HTTP_ACCEPT'] = 'application/json' }
  end
end
