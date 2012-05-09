module OpenStack
  module Compute
    module Conn
      module RoleAspect
         def get_roles()
        response = req("get","/OS-KSADM/roles")
        OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
        OpenStack::Compute.symbolize_keys(JSON.parse(response.body)["roles"])       

       end
      def get_user_roles(user_id)
         response = req("get","/users/#{user_id}/roles")
        OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
        OpenStack::Compute.symbolize_keys(JSON.parse(response.body)["roles"])       
      end
def get_user_role_for_tenant(user_id,tenant_id)
       response = req("get","/tenants/#{tenant_id}/users/#{user_id}/roles")
        OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
        OpenStack::Compute.symbolize_keys(JSON.parse(response.body)["roles"])
      
end

      end
    end
  end
end