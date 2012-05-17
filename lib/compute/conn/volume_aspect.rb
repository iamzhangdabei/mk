module OpenStack
  module Compute
    module Conn
      module VolumeAspect

        def create_attachment(server_id,volume_id,device)
          data = JSON.generate(:volumeAttachment => {"device"=>"#{device}", "volumeId"=>"#{volume_id}"})
          response = csreq("POST",svrmgmthost,"#{svrmgmtpath}/servers/#{server_id}/os-volume_attachments",svrmgmtport,svrmgmtscheme,{'content-type' => 'application/json'},data)
           #p response.body
          #OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
          #volume= JSON.parse(response.body)['volumeAttachment']
         # return volume
        end
        
        def list_volumes
          response = req("get","/os-volumes/detail")
          OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
          OpenStack::Compute.symbolize_keys(JSON.parse(response.body)["volumes"])
        end

        alias :volumes :list_volumes

        def get_volume(id)
          response = req("get","/os-volumes/#{id}")
          OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
          OpenStack::Compute.symbolize_keys(JSON.parse(response.body)["volume"])
        end

        def create_volume(options)
           """
          Create a volume.

          :param size: Size of volume in GB
          :param snapshot_id: ID of the snapshot
          :param display_name: Name of the volume
          :param display_description: Description of the volume
          :rtype: :class:`Volume`
          """
          #body = {'volume': {'size': size,
          #                    'snapshot_id': snapshot_id,
          #                    'display_name': display_name,
          #                    'display_description': display_description}}
          data = JSON.generate(:volume => options)
          response = csreq("POST",svrmgmthost,"#{svrmgmtpath}/os-volumes",svrmgmtport,svrmgmtscheme,{'content-type' => 'application/json'},data)
          OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
          volume= JSON.parse(response.body)['volume']
          return volume
        end

        def delete_volume(id)
          response = req("DELETE","/os-volumes/#{id}")
          OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
          #OpenStack::Compute.symbolize_keys(JSON.parse(response.body)["volume"])
        end

        def update_volume(id,options)
          response = erq("POST","/os-volumes/#{id}",options)
          OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
          OpenStack::Compute.symbolize_keys(JSON.parse(response.body)["volume"])
        end
        #{"snapshot": {"display_name": "display_nameeeee", "force": false, "display_description": "descriptionnnnnnn", "volume_id": 2}}'

        def make_snapshot_for_volume(volume_id,options)
          #p options
           server_id =   get_volume(volume_id)[:attachments][0][:serverId]

          data = JSON.generate(:snapshot => options)
          #
          p data
          response = csreq("POST",svrmgmthost,"/v1/7c1b416fd8c9441a83d25ea239e2ae7a/snapshots",svrmgmtport,svrmgmtscheme,{'content-type' => 'application/json'},data)
         
          #response = csreq("POST",svrmgmthost,"#{svrmgmtpath.to_s.gsub("v2.0","v1")}/#{server_id}/snapshots",svrmgmtport,svrmgmtscheme,{'content-type' => 'application/json'},data)
         
        #  response = csreq("POST",svrmgmthost,"#{svrmgmtpath}/snapshots",svrmgmtport,svrmgmtscheme,{'content-type' => 'application/json'},data)
          p response.body
          #OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
          #OpenStack::Compute.symbolize_keys(JSON.parse(response.body)["volume"])
       
        end
      end
    end
  end
end
      