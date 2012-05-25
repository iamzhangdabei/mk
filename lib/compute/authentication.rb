module OpenStack
module Compute

  class Authentication

    # Performs an authentication to the OpenStack auth server.
    # If it succeeds, it sets the svrmgmthost, svrmgtpath, svrmgmtport,
    # svrmgmtscheme, authtoken, and authok variables on the connection.
    # If it fails, it raises an exception.
    
    def self.init(conn)
      if conn.auth_path =~ /.*v2.0\/?$/
        AuthV20.new(conn)
      else
        AuthV10.new(conn)
      end
    end

  end

  private
  class AuthV20
    attr_reader :uri
    
    def initialize(connection)
      begin
        server = Net::HTTP::Proxy(connection.proxy_host, connection.proxy_port).new(connection.auth_host, connection.auth_port)
        if connection.auth_scheme == "https"
          server.use_ssl = true
          server.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        server.start
      rescue
        raise OpenStack::Compute::Exception::Connection, "Unable to connect to #{server}"
      end
      
      @uri = String.new

      if connection.auth_method == "password"
        auth_data = JSON.generate({ "auth" =>  { "passwordCredentials" => { "username" => connection.authuser, "password" => connection.authkey }, "tenantName" => connection.authtenant}})
      elsif connection.auth_method == "rax-kskey"
        auth_data = JSON.generate({"auth" => {"RAX-KSKEY:apiKeyCredentials" => {"username" => connection.authuser, "apiKey" => connection.authkey}}})
      else
        raise Exception::InvalidArgument, "Unrecognized auth method #{connection.auth_method}"
      end

      response = server.post(connection.auth_path.chomp("/")+"/tokens", auth_data, {'Content-Type' => 'application/json'})

      if (response.code =~ /^20./)
        resp_data=JSON.parse(response.body)
        p resp_data
        connection.authtoken = resp_data['access']['token']['id']
        #p resp_data['access']['serviceCatalog']
        connection.services_status = resp_data['access']['serviceCatalog']
        if connection.keystone
           @uri = URI.parse(resp_data['access']['serviceCatalog'].select{|c| c["type"]=="identity"}[0]["endpoints"][0]["adminURL"])
        elsif connection.glance
          @uri = URI.parse(resp_data['access']['serviceCatalog'].select{|c| c["type"]=="image"}[0]["endpoints"][0]["publicURL"])
        else
          resp_data['access']['serviceCatalog'].each do |service|
            if connection.service_name
              check_service_name = connection.service_name
            else
              check_service_name = service['name']
            end     
            if service['type'] == connection.service_type and service['name'] == check_service_name
              endpoints = service["endpoints"]
              if connection.region
                endpoints.each do |ep|
                  if ep["region"] and ep["region"].upcase == connection.region.upcase  
                    @uri = URI.parse(ep["publicURL"])
                  end
                end
              else
                @uri = URI.parse(endpoints[0]["publicURL"])
              end
            end
          end
        end
        if @uri == ""
          raise OpenStack::Compute::Exception::Authentication, "No API endpoint for region #{connection.region}"
        else
          connection.svrmgmthost = @uri.host
          connection.svrmgmtpath = @uri.path
          connection.svrmgmtport = @uri.port
          connection.svrmgmtscheme = @uri.scheme
          connection.authok = true
        end
      else
        connection.authtoken = false
        raise OpenStack::Compute::Exception::Authentication, "Authentication failed with response code #{response.code}"
      end
      server.finish
    end
  end

  class AuthV10
    
    def initialize(connection)
      hdrhash = { "X-Auth-User" => connection.authuser, "X-Auth-Key" => connection.authkey }
      begin
        server = Net::HTTP::Proxy(connection.proxy_host, connection.proxy_port).new(connection.auth_host, connection.auth_port)
        if connection.auth_scheme == "https"
          server.use_ssl = true
          server.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        server.start
      rescue
        raise OpenStack::Compute::Exception::Connection, "Unable to connect to #{server}"
      end
      response = server.get(connection.auth_path, hdrhash)
      if (response.code =~ /^20./)
        connection.authtoken = response["x-auth-token"]
        uri = URI.parse(response["x-server-management-url"])
        connection.svrmgmthost = uri.host
        connection.svrmgmtpath = uri.path
        connection.svrmgmtport = uri.port
        connection.svrmgmtscheme = uri.scheme
        connection.authok = true
      else
        connection.authtoken = false
        raise OpenStack::Compute::Exception::Authentication, "Authentication failed with response code #{response.code}"
      end
      server.finish
    end
  end

end
end
