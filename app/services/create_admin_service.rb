class CreateAdminService
  def call
    #user = User.find_or_create_by!(email: Rails.application.secrets.admin_email) do |user|
     #   user.password = Rails.application.secrets.admin_password
     #   user.password_confirmation = Rails.application.secrets.admin_password
        #user.role = :admin
    #end
    User.create(email: Rails.application.secrets.admin_email, role: :admin, password: Rails.application.secrets.admin_password,password_confirmation: Rails.application.secrets.admin_passwor)
  end
end
