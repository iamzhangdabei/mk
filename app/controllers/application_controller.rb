class ApplicationController < ActionController::Base
  protect_from_forgery
  include AuthenticatedSystem
  include OpenStack
  before_filter :reload_compute
  def compute
    return @compute if defined?(@compute)
    @compute =  OpenStack::Compute::Connection.new(:username => current_user.username, :api_key => current_user.api_key, :auth_url => current_user.auth_url)
  end
  def reload_compute
    if params[:tenant_id]
      puts current_tenant[:name]
      @compute =  OpenStack::Compute::Connection.new(:username => current_user.username, :api_key => current_user.api_key, :auth_url => current_user.auth_url,:authtenant=>current_tenant["name"])
    end
  end
  def keystone
    return @keystone if defined?(@keystone)
    @compute = OpenStack::Compute::Connection.new(:username => current_user.username, :api_key => current_user.api_key, :auth_url => current_user.auth_url,:keystone=>true) 
#puts cs
#p  JSON.parse(cs.req("get","/users").body)
#p  JSON.parse(cs.req("post","/users",{"user"=>{"id"=>}}).body)
 
  end
  def current_tenant
    if params[:tenant_id]
      tenants =  JSON.parse(keystone.req("get","/tenants").body)["tenants"]
      tenant = tenants.select{|c| c["id"]==params[:tenant_id]}[0]
    elsif @tenant
      tenant = @tenant
    end
  end
  def glance
    return @glance if defined?(@glance)
    @glance =  OpenStack::Compute::Connection.new(:username => current_user.username, :api_key => current_user.api_key, :auth_url => current_user.auth_url,:glance=>true) 
  end

  helper_method :compute,:keystone,:glance,:current_tenant
end
