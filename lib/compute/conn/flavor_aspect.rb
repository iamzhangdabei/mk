module OpenStack
  module Compute
    module Conn
      module FlavorAspect

        # Returns an array of hashes listing all available server flavors.  The :id key in the hash can be used when flavorRef is required.
        #
        # You can also provide :limit and :offset parameters to handle pagination.
        #
        #   >> cs.list_flavors
        #   => [{:name=>"256 server", :id=>1, :ram=>256, :disk=>10}, 
        #       {:name=>"512 server", :id=>2, :ram=>512, :disk=>20},...
        #
        #   >> cs.list_flavors(:limit => 3, :offset => 2)
        #   => [{:ram=>1024, :disk=>40, :name=>"1GB server", :id=>3}, 
        #       {:ram=>2048, :disk=>80, :name=>"2GB server", :id=>4}, 
        #       {:ram=>4096, :disk=>160, :name=>"4GB server", :id=>5}]       
        def list_flavors(options = {})
          path = OpenStack::Compute.paginate(options).empty? ? "#{svrmgmtpath}/flavors/detail" : "#{svrmgmtpath}/flavors/detail?#{OpenStack::Compute.paginate(options)}"
          response = csreq("GET",svrmgmthost,path,svrmgmtport,svrmgmtscheme)
          OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
          OpenStack::Compute.symbolize_keys(JSON.parse(response.body)['flavors'])
        end
        alias :flavors :list_flavors
        
        # Returns a OpenStack::Compute::Flavor object for the flavor identified by the provided ID.
        #
        #   >> flavor = cs.flavor(1)
        #   => #<OpenStack::Compute::Flavor:0x10156dcc0 @name="256 server", @disk=10, @id=1, @ram=256>
        def get_flavor(id)
          OpenStack::Compute::Flavor.new(self,id)
        end
        alias :flavor :get_flavor
        #to be finished
        def create_flavor(options)
          data = JSON.generate(:flavor => options)
          response = csreq("POST",svrmgmthost,"#{svrmgmtpath}/flavors",svrmgmtport,svrmgmtscheme,{'content-type' => 'application/json'},data)
          OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
          flavor= JSON.parse(response.body)['flavor']
          return flavor
        end
      end
    end
  end
end