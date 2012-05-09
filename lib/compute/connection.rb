module OpenStack
  module Compute
    class Connection
      include  ::OpenStack::Compute::Conn::FlavorAspect
      include  ::OpenStack::Compute::Conn::ImageAspect
      include  ::OpenStack::Compute::Conn::RoleAspect
      include  ::OpenStack::Compute::Conn::ServerAspect
      include  ::OpenStack::Compute::Conn::SnapshotAspect
      include  ::OpenStack::Compute::Conn::TenantAspect
      include  ::OpenStack::Compute::Conn::UserAspect
      include  ::OpenStack::Compute::Conn::VolumeAspect
      attr_reader   :authuser
      attr_reader   :authtenant
      attr_reader   :authkey
      attr_reader   :auth_method
      attr_accessor :authtoken
      attr_accessor :authok
      attr_accessor :svrmgmthost
      attr_accessor :svrmgmtpath
      attr_accessor :svrmgmtport
      attr_accessor :svrmgmtscheme
      attr_reader   :auth_host
      attr_reader   :auth_port
      attr_reader   :auth_scheme
      attr_reader   :auth_path
      attr_reader   :service_name
      attr_reader   :service_type
      attr_reader   :proxy_host
      attr_reader   :proxy_port
      attr_reader   :region
      attr_accessor :keystone
      attr_accessor :glance
      attr_accessor :services_status
      
      # Creates a new OpenStack::Compute::Connection object.  Uses OpenStack::Compute::Authentication to perform the login for the connection.
      #
      # The constructor takes a hash of options, including:
      #
      #   :username - Your Openstack username *required*
      #   :tenant - Your Openstack tenant *required*. Defaults to username.
      #   :api_key - Your Openstack API key *required*
      #   :auth_url - Configurable auth_url endpoint.
      #   :service_name - (Optional for v2.0 auth only). The optional name of the compute service to use.
      #   :service_type - (Optional for v2.0 auth only). Defaults to "compute"
      #   :region - (Optional for v2.0 auth only). The specific service region to use. Defaults to first returned region.
      #   :retry_auth - Whether to retry if your auth token expires (defaults to true)
      #   :proxy_host - If you need to connect through a proxy, supply the hostname here
      #   :proxy_port - If you need to connect through a proxy, supply the port here
      #
      #   cs = OpenStack::Compute::Connection.new(:username => 'USERNAME', :api_key => 'API_KEY', :auth_url => 'AUTH_URL')
      def initialize(options = {:retry_auth => true}) 
        @authuser = options[:username] || (raise Exception::MissingArgument, "Must supply a :username")
        @authkey = options[:api_key] || (raise Exception::MissingArgument, "Must supply an :api_key")
        @auth_url = options[:auth_url] || (raise Exception::MissingArgument, "Must supply an :auth_url")
        @authtenant = options[:authtenant] || @authuser
        @auth_method = options[:auth_method] || "password"
        @service_name = options[:service_name] || nil
        @service_type = options[:service_type] || "compute"
        @region = options[:region] || @region = nil
        @is_debug = options[:is_debug]
        @keystone = options[:keystone] || false
        @glance = options[:glance] || false
        auth_uri=nil
        begin
          auth_uri=URI.parse(@auth_url)
        rescue Exception => e
          raise Exception::InvalidArgument, "Invalid :auth_url parameter: #{e.message}"
        end
        raise Exception::InvalidArgument, "Invalid :auth_url parameter." if auth_uri.nil? or auth_uri.host.nil?
        @auth_host = auth_uri.host
        @auth_port = auth_uri.port
        @auth_scheme = auth_uri.scheme
        @auth_path = auth_uri.path
        @retry_auth = options[:retry_auth]
        @proxy_host = options[:proxy_host]
        @proxy_port = options[:proxy_port]
        @authok = false
        @http = {}
        OpenStack::Compute::Authentication.init(self)
      end
      
      # Returns true if the authentication was successful and returns false otherwise.
      #
      #   cs.authok?
      #   => true
      def authok?
        @authok
      end

      # This method actually makes the HTTP REST calls out to the server
      def csreq(method,server,path,port,scheme,headers = {},data = nil,attempts = 0) # :nodoc:
        start = Time.now
        hdrhash = headerprep(headers)
        start_http(server,path,port,scheme,hdrhash)
        request = Net::HTTP.const_get(method.to_s.capitalize).new(path,hdrhash)
        request.body = data
        response = @http[server].request(request)
        if @is_debug
            puts "REQUEST: #{method} => #{path}"
            puts data if data
            puts "RESPONSE: #{response.body}"
            puts '----------------------------------------'
        end
        raise OpenStack::Compute::Exception::ExpiredAuthToken if response.code == "401"
        response
      rescue Errno::EPIPE, Timeout::Error, Errno::EINVAL, EOFError
        # Server closed the connection, retry
        raise OpenStack::Compute::Exception::Connection, "Unable to reconnect to #{server} after #{attempts} attempts" if attempts >= 5
        attempts += 1
        @http[server].finish if @http[server].started?
        start_http(server,path,port,scheme,headers)
        retry
      rescue OpenStack::Compute::Exception::ExpiredAuthToken
        raise OpenStack::Compute::Exception::Connection, "Authentication token expired and you have requested not to retry" if @retry_auth == false
        OpenStack::Compute::Authentication.init(self)
        retry
      end

      # This is a much more sane way to make a http request to the api.
      # Example: res = conn.req('GET', "/servers/#{id}")
      def req(method, path, options = {})
        server   = options[:server]   || @svrmgmthost
        port     = options[:port]     || @svrmgmtport
        scheme   = options[:scheme]   || @svrmgmtscheme
        headers  = options[:headers]  || {'content-type' => 'application/json'}
        data     = options[:data]
        attempts = options[:attempts] || 0
        path = @svrmgmtpath + path
        res = csreq(method,server,path,port,scheme,headers,data,attempts)
        if not res.code.match(/^20.$/)
          OpenStack::Compute::Exception.raise_exception(res)
        end
        return res
      end

      def quotas(keystone)
        response = req("get","/os-quota-sets/#{keystone.current_tenant[:id]}")
        OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
        OpenStack::Compute.symbolize_keys(JSON.parse(response.body))
      end
      # Returns the current state of the programatic API limits.  Each account has certain limits on the number of resources
      # allowed in the account, and a rate of API operations.
      #
      # The operation returns a hash.  The :absolute hash key reveals the account resource limits, including the maxmimum 
      # amount of total RAM that can be allocated (combined among all servers), the maximum members of an IP group, and the 
      # maximum number of IP groups that can be created.
      #
      # The :rate hash key returns an array of hashes indicating the limits on the number of operations that can be performed in a 
      # given amount of time.  An entry in this array looks like:
      #
      #   {:regex=>"^/servers", :value=>50, :verb=>"POST", :remaining=>50, :unit=>"DAY", :resetTime=>1272399820, :URI=>"/servers*"}
      #
      # This indicates that you can only run 50 POST operations against URLs in the /servers URI space per day, we have not run
      # any operations today (50 remaining), and gives the Unix time that the limits reset.
      #
      # Another example is:
      # 
      #   {:regex=>".*", :value=>10, :verb=>"PUT", :remaining=>10, :unit=>"MINUTE", :resetTime=>1272399820, :URI=>"*"}
      #
      # This says that you can run 10 PUT operations on all possible URLs per minute, and also gives the number remaining and the
      # time that the limit resets.
      #
      # Use this information as you're building your applications to put in relevant pauses if you approach your API limitations.
      def limits
        response = csreq("GET",svrmgmthost,"#{svrmgmtpath}/limits",svrmgmtport,svrmgmtscheme)
        OpenStack::Compute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
        OpenStack::Compute.symbolize_keys(JSON.parse(response.body)['limits'])
      end
      
      private
      
      # Sets up standard HTTP headers
      def headerprep(headers = {}) # :nodoc:
        default_headers = {}
        default_headers["X-Auth-Token"] = @authtoken if (authok? && @account.nil?)
        default_headers["X-Storage-Token"] = @authtoken if (authok? && !@account.nil?)
        default_headers["Connection"] = "Keep-Alive"
        default_headers["User-Agent"] = "OpenStack::Compute Ruby API #{VERSION}"
        default_headers["Accept"] = "application/json"
        default_headers.merge(headers)
      end
      
      # Starts (or restarts) the HTTP connection
      def start_http(server,path,port,scheme,headers) # :nodoc:
        if (@http[server].nil?)
          begin
            @http[server] = Net::HTTP::Proxy(self.proxy_host, self.proxy_port).new(server,port)
            if scheme == "https"
              @http[server].use_ssl = true
              @http[server].verify_mode = OpenSSL::SSL::VERIFY_NONE
            end
            @http[server].start
          rescue
            raise OpenStack::Compute::Exception::Connection, "Unable to connect to #{server}"
          end
        end
      end
    end
  end
end
