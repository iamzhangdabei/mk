class UserSessionsController < ApplicationController
  layout 'login'
  def new
    @user_session = UserSession.new
  end
  
  def create
    session[:username] =  params[:username]
    session[:api_key]  =  params[:api_key]
    session[:url] = params[:url]
    tenant= params[:user_name]
    tenant = params[:tenant] unless params[:tenant].blank?
    begin
      @compute =  OpenStack::Compute::Connection.new(:tenant=>tenant,:username => params[:username], :api_key => params[:api_key], :auth_url => params[:url])
      return redirect_to tenants_path
    rescue  OpenStack::Compute::Exception::Authentication
      session[:username] = nil
      session[:api_key]  =  nil
      session[:url] = nil
      flash[:notice] = "Login failed!"
      return redirect_to login_path
    end
    
  end
  
  def destroy
    session[:username] = nil
    session[:api_key]  =  nil
    session[:url] = nil
    flash[:notice] = "Logout successful!"
    redirect_back_or_default new_user_sessions_url
  end
end
