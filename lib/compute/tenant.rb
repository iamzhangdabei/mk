module OpenStack
  module Compute
    class Tenant
      require 'compute/metadata'
      attr_reader :id
      attr_reader :name
      attr_reader :description
      attr_reader :enable
      def initialize(options)
        @id = options["id"]
        @name = options["name"]
        @description = options["description"]
        @enable = options["enable"]
      end
    end
  end
end
