class PageController < ApplicationController
  def quotas
    @quotas = current_connection.quotas(current_admin_connection)
  end
  def services
    @services = current_connection.services_status
  end
end
