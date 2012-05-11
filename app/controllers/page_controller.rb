class PageController < ApplicationController
  def quotas
    @quotas = compute.quotas(keystone)
  end
  def services
    @services = compute.services_status
  end
  def tenant
    @tenant = keystone.get_tenants_for_user(keystone.current_auth_user[:id])[0]
  end
  def admin
    redirect_to tenants_path
  end
end
