class ApplicationController < ActionController::Base
  protect_from_forgery
  include OpenStack
  include AuthenticatedSystem
  before_filter :reload_compute
  def compute
    return @compute if defined?(@compute)
    @compute =  OpenStack::Compute::Connection.new(:username => session[:username], :api_key => session[:api_key], :auth_url => session[:url])
  end
  def reload_compute
    if params[:tenant_id]
      
      @compute =  OpenStack::Compute::Connection.new(:username => session[:username], :api_key => session[:api_key], :auth_url => session[:url],:authtenant=>current_tenant["name"])
    end
  end
  def keystone
    return @keystone if defined?(@keystone)
    @compute = OpenStack::Compute::Connection.new(:username => session[:username], :api_key => session[:api_key], :auth_url => session[:url],:keystone=>true) 
#puts cs
#p  JSON.parse(cs.req("get","/users").body)
#p  JSON.parse(cs.req("post","/users",{"user"=>{"id"=>}}).body)
 
  end
  def current_tenant
    if params[:tenant_id]
        keystone.current_tenant
    elsif @tenant
      tenant = @tenant
    end
  end
  def glance
    return @glance if defined?(@glance)
    @glance =  OpenStack::Compute::Connection.new(:username => session[:username], :api_key => session[:api_key], :auth_url => session[:url],:glance=>true) 
  end
  def require_login
  end
  helper_method :compute,:keystone,:glance,:current_tenant
end
