class ApplicationController < ActionController::Base
  protect_from_forgery
  include AuthenticatedSystem
  include OpenStack
  
    def compute
    return @compute if defined?(@compute)
    @compute =  OpenStack::Compute::Connection.new(:username => current_user.username, :api_key => current_user.api_key, :auth_url => current_user.auth_url)
  end
  def reload_compute(options)
    options.merge()
    @compute =  OpenStack::Compute::Connection.new(:username => current_user.username, :api_key => current_user.api_key, :auth_url => current_user.auth_url,options)
  end
  def keystone
    return @keystone if defined?(@keystone)
    @compute = OpenStack::Compute::Connection.new(:username => current_user.username, :api_key => current_user.api_key, :auth_url => current_user.auth_url,:keystone=>true) 
#puts cs
#p  JSON.parse(cs.req("get","/users").body)
#p  JSON.parse(cs.req("post","/users",{"user"=>{"id"=>}}).body)
 
  end
  def current_tenant(username)
    tenants =  JSON.parse(keystone.req("get","/tenants").body)["tenants"]
    tenant = tenants.select{|c| c["name"]==username}[0]
  end
  def glance
    return @glance if defined?(@glance)
    @glance =  OpenStack::Compute::Connection.new(:username => current_user.username, :api_key => current_user.api_key, :auth_url => current_user.auth_url,:glance=>true) 
  end

  helper_method :compute,:keystone,:glance
end
