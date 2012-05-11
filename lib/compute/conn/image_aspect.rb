module OpenStack
  module Compute
    module Conn
      module ImageAspect
        # Returns an array of hashes listing available server images that you have access too, including stock OpenStack Compute images and 
        # any that you have created.  The "id" key in the hash can be used where imageRef is required.
        #
        # You can also provide :limit and :offset parameters to handle pagination.
        #
        #   >> cs.list_images
        #   => [{:name=>"CentOS 5.2", :id=>2, :updated=>"2009-07-20T09:16:57-05:00", :status=>"ACTIVE", :created=>"2009-07-20T09:16:57-05:00"}, 
        #       {:name=>"Gentoo 2008.0", :id=>3, :updated=>"2009-07-20T09:16:57-05:00", :status=>"ACTIVE", :created=>"2009-07-20T09:16:57-05:00"},...
        #
        #   >> cs.list_images(:limit => 3, :offset => 2) 
        #   => [{:status=>"ACTIVE", :name=>"Fedora 11 (Leonidas)", :updated=>"2009-12-08T13:50:45-06:00", :id=>13}, 
        #       {:status=>"ACTIVE", :name=>"CentOS 5.3", :updated=>"2009-08-26T14:59:52-05:00", :id=>7}, 
        #       {:status=>"ACTIVE", :name=>"CentOS 5.4", :updated=>"2009-12-16T01:02:17-06:00", :id=>187811}]
        def list_images(options = {})
          path = OpenStack::Compute.paginate(options).empty? ? "#{svrmgmtpath}/images/detail" : "#{svrmgmtpath}/images/detail?#{OpenStack::Compute.paginate(options)}"
          response = csreq("GET",svrmgmthost,path,svrmgmtport,svrmgmtscheme)
          OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
          OpenStack::Compute.symbolize_keys(JSON.parse(response.body)['images'])
        end
        alias :images :list_images
        
        # Returns a OpenStack::Compute::Image object for the image identified by the provided id.
        #
        #   >> image = cs.get_image(8)
        #   => #<OpenStack::Compute::Image:0x101659698 ...>
        def get_image(id)
          OpenStack::Compute::Image.new(self,id)
        end
        def get_image_detail(id)
            response =  req("get","/images/#{id}")
            OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
            OpenStack::Compute.symbolize_keys(JSON.parse(response.body)["image"])
     
        end
        alias :image :get_image

      end
    end
  end
end