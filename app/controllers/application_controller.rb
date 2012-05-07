class ApplicationController < ActionController::Base
  protect_from_forgery
  include AuthenticatedSystem
  include OpenStack
  def current_connection
    return @current_connection if defined?(@current_connection)
    @current_connection =  OpenStack::Compute::Connection.new(:username => current_user.username, :api_key => current_user.api_key, :auth_url => current_user.auth_url)
  end
  def reload_connection(options)
    @current_connection =  OpenStack::Compute::Connection.new(:username => current_user.username, :api_key => current_user.api_key, :auth_url => current_user.auth_url)
  end
  def current_admin_connection
    return @current_admin_connection if defined?(@current_admin_connection)
    @current_connection =  OpenStack::Compute::Connection.new(:username => current_user.username, :api_key => current_user.api_key, :auth_url => current_user.auth_url,:keystone=>true) 
#puts cs
#p  JSON.parse(cs.req("get","/users").body)
#p  JSON.parse(cs.req("post","/users",{"user"=>{"id"=>}}).body)
 
  end
  def current_tenant(username)
    tenants =  JSON.parse(current_admin_connection.req("get","/tenants").body)["tenants"]
    tenant = tenants.select{|c| c["name"]==username}[0]
  end
  def glance
 return @glance if defined?(@glance)
    @glance =  OpenStack::Compute::Connection.new(:username => current_user.username, :api_key => current_user.api_key, :auth_url => current_user.auth_url,:glance=>true) 
  end
  helper_method :current_connection,:current_admin_connection,:glance
end
