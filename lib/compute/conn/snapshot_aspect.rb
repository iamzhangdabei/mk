module OpenStack
  module Compute
    module Conn
      module SnapshotAspect
        def snapshots
           response = req("get","/os-snapshots")
          OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
          OpenStack::Compute.symbolize_keys(JSON.parse(response.body))["snapshots"]
        end
        def get_snapshot(id)
              response = req("get","/os-snapshots/#{id}")
          OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
          OpenStack::Compute.symbolize_keys(JSON.parse(response.body))["snapshot"]
     
        end
        def delete_snapshot(id)
          response = req("DELETE","/os-snapshots/#{id}")
          OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
        end
        #{"snapshot=>{"volume_id"=>,'force'=>false,'display_name'=>,'display_description'=>,}"}
        def create_snapshot(options)
           data = JSON.generate(:snapshot => options)
          response = csreq("POST",svrmgmthost,"#{svrmgmtpath}/os-snapshots",svrmgmtport,svrmgmtscheme,{'content-type' => 'application/json'},data)
          OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
          snapshot= JSON.parse(response.body)['snapshot']
          return snapshot
        end
     end
    end
  end
end