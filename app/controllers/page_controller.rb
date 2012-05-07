class PageController < ApplicationController
  def quotas
    @quotas = compute.quotas(keystone)
  end
  def services
    @services = compute.services_status
  end
end
