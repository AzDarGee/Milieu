class SessionsController < ApplicationController
  before_action :update_activity_time
  before_action :session_expiry, except: [:create]

  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user && @user.authenticate(params[:session][:password])
      session[:user_id] = @user.id
      redirect_to root_path, notice: t('sessions.notice.welcome')
    else
      redirect_to new_session_path, alert: t('sessions.alert.could_not_signin')
    end
  end

  def destroy
    session.delete(:user_id) if signed_in?
    redirect_to root_path
  end

  private

  def update_activity_time
    session[:expires_at] = 24.hours.from_now
  end

  def session_expiry
    get_session_time_left
    log_out if @session_time_left <= 0
  end

  def get_session_time_left
    expire_time = session[:expires_at] || Time.now
    @session_time_left = (expire_time.to_time - Time.now).to_i
  end

end
