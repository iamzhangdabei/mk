module OpenStack
  module Compute
    module Conn
      module TenantAspect
        def get_tenants_for_user(user_id)
          all_roles =  JSON.parse(req("get","/users/#{user_id}/roleRefs").body)["roles"]
          tenantids = all_roles.collect{|c| c["tenantId"]}
          all_tenants =  JSON.parse(req("get","/tenants").body)["tenants"]
          all_tenants.select{|c| tenantids.include?(c["id"])}
        end

        def tenants(options={})
          path = OpenStack::Compute.paginate(options).empty? ? "#{svrmgmtpath}/tenants" : "#{svrmgmtpath}/tenants?#{OpenStack::Compute.paginate(options)}"
          response = csreq("GET",svrmgmthost,path,svrmgmtport,svrmgmtscheme)
          OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
          OpenStack::Compute.symbolize_keys(JSON.parse(response.body)["tenants"])
        end
        def get_roles(tenant_id)
          response = req("GET","/tenants/#{id}")
          OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
          OpenStack::Compute.symbolize_keys(JSON.parse(response.body)["tenant"])
  
        end
        def get_tenant(id)
          response = req("GET","/tenants/#{id}")
          OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
          OpenStack::Compute.symbolize_keys(JSON.parse(response.body)["tenant"])
        end
#{"tenant": {"enabled": "true", "name": "test_tenant", "description": "test_tenant"}}
        #params={"tenant"=>{"name"=>"","description"=>"",:enabled=>true}}
        def create_tenant(options)
          #raise OpenStack::Compute::Exception::MissingArgument, "Server name, flavorRef, and imageRef, must be supplied" unless (options[:name] && options[:flavorRef] && options[:imageRef])
          data = JSON.generate(:tenant => options)
          response = csreq("POST",svrmgmthost,"#{svrmgmtpath}/tenants",svrmgmtport,svrmgmtscheme,{'content-type' => 'application/json'},data)
          OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
          tenant= JSON.parse(response.body)['tenant']
          return tenant
        end
#{"tenant": {"description": "test_tenant", "enabled": "true", "id": "621d7ebac2ba41b48902907c35246bd6", "name": "testttt_tenant"}}'

        def update_tenant(options)
          #raise OpenStack::Compute::Exception::MissingArgument, "Server name, flavorRef, and imageRef, must be supplied" unless (options[:name] && options[:flavorRef] && options[:imageRef])
          data = JSON.generate(:tenant => options)
          response = csreq("POST",svrmgmthost,"#{svrmgmtpath}/tenants/#{options[:id]}",svrmgmtport,svrmgmtscheme,{'content-type' => 'application/json'},data)
          OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
          tenant= JSON.parse(response.body)['tenant']
          return tenant
        end

        def delete_tenant(tenant_id)
          response = req("DELETE","/tenants/#{tenant_id}")
          OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
        end

        def add_user_to_tenant(user_id,tenant_id,role_id)

          response =  req("PUT","/tenants/#{tenant_id}/users/#{user_id}/roles/OS-KSADM/#{role_id}")
           OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
        #  OpenStack::Compute.symbolize_keys(JSON.parse(response.body)["roleRef"])       
       
        end

        def remove_user_from_tenant(user_id,tenant_id)
           response = req("get","/tenants/#{tenant_id}/users/#{user_id}/roles")
          OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
         roles= OpenStack::Compute.symbolize_keys(JSON.parse(response.body)["roles"]) 
       
        # roles = get_user_roles_for_tenant(user_id,tenant_id)
         p roles.class
         roles.each do |role|
          p role
          p role[:id]
            req("DELETE","/tenants/#{tenant_id}/users/#{user_id}/roles/OS-KSADM/#{role[:id]}")
            OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
          end
        end

        def current_tenant
          tenants.select{|c| c[:name]==authuser}[0]
        end
      end
    end
  end
end