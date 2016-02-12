class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :ensure_user

  def social
    if request.env['omniauth.auth'].provider == 'facebook' && request.env['omniauth.auth'].info.email.blank? || request.env['omniauth.auth'].extra.raw_info.birthday.blank?
      redirect_to '/users/auth/facebook?auth_type=rerequest&scope=email,user_birthday'
    else
      @user = User.from_omniauth(request.env['omniauth.auth'], current_user)
      if @user.persisted?
        sign_in_and_redirect @user
        set_flash_message(:notice, :success, :kind => 'Facebook') if is_navigational_format?
      else
        puts request.env['omniauth.auth']
        flash[:error] = "We're sorry, we failed to sign you in."
        redirect_to root_url
      end
    end
  end

  alias_method :facebook, :social
end