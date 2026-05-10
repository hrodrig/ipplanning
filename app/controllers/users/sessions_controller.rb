# frozen_string_literal: true

# Same rationale as Admins::SessionsController (Devise default :recall breaks CSRF on failure).
class Users::SessionsController < Devise::SessionsController
  protected

  def auth_options
    { scope: resource_name, locale: I18n.locale }
  end
end
