module Users
  class RegistrationsController < Devise::RegistrationsController
    layout 'application', only: [:edit]
  end
end
