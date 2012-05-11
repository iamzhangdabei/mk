#!/usr/bin/env ruby
# 
# == Ruby OpenStack Compute API
#
# See COPYING for license information.
# ----
# 
# === Documentation & Examples
# To begin reviewing the available methods and examples, view the README.rdoc file, or begin by looking at documentation for the OpenStack::Compute::Connection class.
#
# Example:
# OpenStack::Compute::Connection.new(:username => USERNAME, :api_key => API_KEY, :auth_url => API_URL) method.
module OpenStack
module Compute

  VERSION = "1.0"
  require 'net/http'
  require 'net/https'
  require 'uri'
  require 'rubygems'
  require 'json'
  require 'date'

  unless "".respond_to? :each_char
    require "jcode"
    $KCODE = 'u'
  end
  require 'compute/conn/flavor_aspect'
  require 'compute/conn/image_aspect'
  require 'compute/conn/role_aspect'
  require 'compute/conn/server_aspect'
  require 'compute/conn/snapshot_aspect'
  require 'compute/conn/tenant_aspect'
  require 'compute/conn/user_aspect'
  require 'compute/conn/volume_aspect'
  require 'compute/exception'
  require 'compute/authentication'
  require 'compute/connection'
  require 'compute/server'
  require 'compute/image'
  require 'compute/flavor'
  
  require 'compute/address'
  require 'compute/personalities'

  
  # Constants that set limits on server creation
  MAX_PERSONALITY_ITEMS = 5
  MAX_PERSONALITY_FILE_SIZE = 10240
  MAX_SERVER_PATH_LENGTH = 255

  # Helper method to recursively symbolize hash keys.
  def original_symbolize_keys(obj)
    case obj
    when Array
      obj.inject([]){|res, val|
        res << case val
        when Hash, Array
            symbolize_keys(val)
        else
          val
        end
        res
      }
    when Hash
      obj.inject({}){|res, (key, val)|
        nkey = case key
        when String
          key.to_sym
        else
          key
        end
        nval = case val
        when Hash, Array
          symbolize_keys(val)
        else
          val
        end
        res[nkey] = nval
        res
      }
    else
      obj
    end
  end
  def self.symbolize_keys(obj)

    if obj.is_a?(Hash)

      HashWithIndifferentAccess.new(obj)
    elsif obj.is_a?(Array)

      obj.collect{|c| HashWithIndifferentAccess.new(c)}
    else

      obj
    end
  end
  def self.paginate(options = {})
    path_args = []
    path_args.push(URI.encode("limit=#{options[:limit]}")) if options[:limit]
    path_args.push(URI.encode("offset=#{options[:offset]}")) if options[:offset]
    path_args.join("&")
  end

end
end
