module OpenStack
  module Compute
    module Conn
      module RoleAspect

        def roles
          response = req("get","/OS-KSADM/roles")
          OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
          OpenStack::Compute.symbolize_keys(JSON.parse(response.body)["roles"])       
        end
        def get_user_roles(user_id)
           response = req("get","/users/#{user_id}/roleRefs")
          OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
          OpenStack::Compute.symbolize_keys(JSON.parse(response.body)["roles"])       
        end
        def get_user_role_for_tenant(user_id,tenant_id)
          response = req("get","/tenants/#{tenant_id}/users/#{user_id}/roles")
          OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
          OpenStack::Compute.symbolize_keys(JSON.parse(response.body)["roles"]) 
        end
        def check_admin_for_user(user_id)
          get_user_roles(user_id).collect{|c| c[:roleId]}.include?(role_id_for_admin)
        end
        
        def role_id_for_admin
          roles.select{|c| c["name"]=="admin"}[0]["id"]
        end

      end
    end
  end
end