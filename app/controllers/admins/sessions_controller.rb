# frozen_string_literal: true

# Devise's default +auth_options+ sets Warden +:recall+ to +sessions#new+, so a failed login
# re-dispatches a POST into +new+ with the same form params. That breaks CSRF / Turbo and
# surfaces InvalidAuthenticityToken instead of the normal "invalid credentials" flash.
# Without +:recall+, Devise::FailureApp uses +redirect+ (GET sign-in + flash).
class Admins::SessionsController < Devise::SessionsController
  protected

  def auth_options
    { scope: resource_name, locale: I18n.locale }
  end
end
