class PageController < ApplicationController
  before_filter :login_required
  def quotas
    @quotas = compute.quotas(keystone)
  end
  def edit_quotas
    
  end
  def services
    @services = compute.services_status
  end
  def tenant
    tenant_id = keystone.get_tenants_for_user(keystone.current_auth_user[:id])[0]["id"]

    redirect_to "/tenants/#{tenant_id}/servers"
  end
  def admin
    redirect_to tenants_path
  end
end
