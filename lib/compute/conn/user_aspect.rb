module OpenStack
  module Compute
    module Conn
      module UserAspect

        def get_users_for_tenant(tenant_id)
          response = req("get","/tenants/#{tenant_id}/users")
          OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
          OpenStack::Compute.symbolize_keys(JSON.parse(response.body)["users"])
        end

        def users(options = {})
         
          anti_cache_param="cacheid=#{Time.now.to_i}"
          path = OpenStack::Compute.paginate(options).empty? ? "#{svrmgmtpath}/users?#{anti_cache_param}" : "#{svrmgmtpath}/users?#{OpenStack::Compute.paginate(options)}&#{anti_cache_param}"
          response = csreq("GET",svrmgmthost,path,svrmgmtport,svrmgmtscheme)
          OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
          OpenStack::Compute.symbolize_keys(JSON.parse(response.body)["users"])
        end

        def get_user(id)
          path =  "#{svrmgmtpath}/users/#{id}"
          response = csreq("GET",svrmgmthost,path,svrmgmtport,svrmgmtscheme)
          OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
          OpenStack::Compute.symbolize_keys(JSON.parse(response.body)["user"])
        end

        #options should be {"user": {"id": base.getid(user),
        #                     "tenantId": base.getid(tenant)}}
        def update_user(user_id,options)
          response = req("POST","/users/#{user_id}",options)
          OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
          OpenStack::Compute.symbolize_keys(JSON.parse(response.body)["user"])
        end
        
        def delete_user(user_id)
          response = req("DELETE","/users/#{user_id}",options)
          OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
          OpenStack::Compute.symbolize_keys(JSON.parse(response.body)["user"])
        end
        def current_auth_user
          users.select{|c| c[:name]==authuser}[0]
        end
      end
    end
  end
end