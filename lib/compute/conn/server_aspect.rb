module OpenStack
  module Compute
    module Conn
      module ServerAspect
        # Returns the OpenStack::Compute::Server object identified by the given id.
        #
        #   >> server = cs.get_server(110917)
        #   => #<OpenStack::Compute::Server:0x101407ae8 ...>
        #   >> server.name
        #   => "MyServer"
        def get_server(id)
          OpenStack::Compute::Server.new(self,id)
        end
        alias :server :get_server
        
        # Returns an array of hashes, one for each server that exists under this account.  The hash keys are :name and :id.
        #
        # You can also provide :limit and :offset parameters to handle pagination.
        #
        #   >> cs.list_servers
        #   => [{:name=>"MyServer", :id=>110917}]
        #
        #   >> cs.list_servers(:limit => 2, :offset => 3)
        #   => [{:name=>"demo-standingcloud-lts", :id=>168867}, 
        #       {:name=>"demo-aicache1", :id=>187853}]
        def list_servers(options = {})
          anti_cache_param="cacheid=#{Time.now.to_i}"
          path = OpenStack::Compute.paginate(options).empty? ? "#{svrmgmtpath}/servers?#{anti_cache_param}" : "#{svrmgmtpath}/servers?#{OpenStack::Compute.paginate(options)}&#{anti_cache_param}"
          response = csreq("GET",svrmgmthost,path,svrmgmtport,svrmgmtscheme)
          OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
          OpenStack::Compute.symbolize_keys(JSON.parse(response.body)["servers"])
        end
        alias :servers :list_servers
        
        # Returns an array of hashes with more details about each server that exists under this account.  Additional information
        # includes public and private IP addresses, status, hostID, and more.  All hash keys are symbols except for the metadata
        # hash, which are verbatim strings.
        #
        # You can also provide :limit and :offset parameters to handle pagination.
        #   >> cs.list_servers_detail
        #   => [{:name=>"MyServer", :addresses=>{:public=>["67.23.42.37"], :private=>["10.176.241.237"]}, :metadata=>{"MyData" => "Valid"}, :imageRef=>10, :progress=>100, :hostId=>"36143b12e9e48998c2aef79b50e144d2", :flavorRef=>1, :id=>110917, :status=>"ACTIVE"}]
        #
        #   >> cs.list_servers_detail(:limit => 2, :offset => 3)
        #   => [{:status=>"ACTIVE", :imageRef=>10, :progress=>100, :metadata=>{}, :addresses=>{:public=>["x.x.x.x"], :private=>["x.x.x.x"]}, :name=>"demo-standingcloud-lts", :id=>168867, :flavorRef=>1, :hostId=>"xxxxxx"}, 
        #       {:status=>"ACTIVE", :imageRef=>8, :progress=>100, :metadata=>{}, :addresses=>{:public=>["x.x.x.x"], :private=>["x.x.x.x"]}, :name=>"demo-aicache1", :id=>187853, :flavorRef=>3, :hostId=>"xxxxxx"}]
        def list_servers_detail(options = {})
          path = OpenStack::Compute.paginate(options).empty? ? "#{svrmgmtpath}/servers/detail" : "#{svrmgmtpath}/servers/detail?#{OpenStack::Compute.paginate(options)}"
          response = csreq("GET",svrmgmthost,path,svrmgmtport,svrmgmtscheme)
          OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
          OpenStack::Compute.symbolize_keys(JSON.parse(response.body)["servers"])
        end
        alias :servers_detail :list_servers_detail
        
        # Creates a new server instance on OpenStack Compute
        # 
        # The argument is a hash of options.  The keys :name, :flavorRef,
        # and :imageRef are required; :metadata and :personality are optional.
        #
        # :flavorRef and :imageRef are href strings identifying a particular
        # server flavor and image to use when building the server.  The :imageRef
        # can either be a stock image, or one of your own created with the
        # server.create_image method.
        #
        # The :metadata argument should be a hash of key/value pairs.  This
        # metadata will be applied to the server at the OpenStack Compute API level.
        #
        # The "Personality" option allows you to include up to five files, # of
        # 10Kb or less in size, that will be placed on the created server.
        # For :personality, pass a hash of the form {'local_path' => 'server_path'}.
        # The file located at local_path will be base64-encoded and placed at the
        # location identified by server_path on the new server.
        #
        # Returns a OpenStack::Compute::Server object.  The root password is
        # available in the adminPass instance method.
        #
        #   >> server = cs.create_server(
        #        :name        => 'NewServer',
        #        :imageRef    => 'http://172.19.0.3/v1.1/images/3',
        #        :flavorRef   => 'http://172.19.0.3/v1.1/flavors/1',
        #        :metadata    => {'Racker' => 'Fanatical'},
        #        :personality => {'/home/bob/wedding.jpg' => '/root/wedding.jpg'})
        #   => #<OpenStack::Compute::Server:0x101229eb0 ...>
        #   >> server.name
        #   => "NewServer"
        #   >> server.status
        #   => "BUILD"
        #   >> server.adminPass
        #   => "NewServerSHMGpvI"
        def create_server(options)
          raise OpenStack::Compute::Exception::MissingArgument, "Server name, flavorRef, and imageRef, must be supplied" unless (options[:name] && options[:flavorRef] && options[:imageRef])
          options[:personality] = Personalities.get_personality(options[:personality])
          data = JSON.generate(:server => options)
          response = csreq("POST",svrmgmthost,"#{svrmgmtpath}/servers",svrmgmtport,svrmgmtscheme,{'content-type' => 'application/json'},data)
          OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
          server_info = JSON.parse(response.body)['server']
          server = OpenStack::Compute::Server.new(self,server_info['id'])
          server.adminPass = server_info['adminPass']
          return server
        end
      end
    end
  end
end