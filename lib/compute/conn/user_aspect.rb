module OpenStack
  module Compute
    module Conn
      module UserAspect

        def create_user(options)
          #{"user": 
          #{"email": "test@qq.com", 
          #  "password": "test", 
          #  "enabled": "true", 
          #  "name": "test",
          #   "tenantId": "admin"}}
          #raise OpenStack::Compute::Exception::MissingArgument, "Server name, flavorRef, and imageRef, must be supplied" unless (options[:name] && options[:flavorRef] && options[:imageRef])
          data = JSON.generate(:user => options)
          response = csreq("POST",svrmgmthost,"#{svrmgmtpath}/users",svrmgmtport,svrmgmtscheme,{'content-type' => 'application/json'},data)
          OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
          p response.body
        end

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
        #{"user": {"name": "test2", "id": "b56e1b27ba2a4dbcb7b764f659b039d8"}}
        def update_user(options)
          data = JSON.generate(:user => options)
           response = csreq("PUT",svrmgmthost,"#{svrmgmtpath}/users/#{options[:id]}",svrmgmtport,svrmgmtscheme,{'content-type' => 'application/json'},data)
        
          #response = req("PUT","/users/#{options[:user_id]}",options)
          OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
          OpenStack::Compute.symbolize_keys(JSON.parse(response.body)["user"])
        end
        
        def delete_user(user_id)
          response = req("DELETE","/users/#{user_id}")
          OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
          #OpenStack::Compute.symbolize_keys(JSON.parse(response.body)["user"])
        end

        def current_auth_user
          users.select{|c| c[:name]==authuser}[0]
        end
        
      end
    end
  end
end