require 'rack'
require 'thin'

module Thrift
  class ThinHTTPServer < BaseServer

    ##
    # Accepts a Thrift::Processor
    # Options include:
    # * :port
    # * :ip
    # * :path
    # * :protocol_factory
    def initialize(processor, options={})
      port = options[:port] || 80
      ip = options[:ip] || "0.0.0.0"
      path = options[:path] || "/"
      protocol_factory = options[:protocol_factory] || BinaryProtocolFactory.new
      app = RackApplication.for(path, processor, protocol_factory)
      @server = Thin::Server.new(ip, port, app)
    end

    ##
    # Starts the server
    def serve
      @server.start
    end

    class RackApplication

      THRIFT_HEADER = "application/x-thrift"

      def self.for(path, processor, protocol_factory)
        Rack::Builder.new do
          use Rack::CommonLogger
          use Rack::ShowExceptions
          use Rack::Lint
          map path do
            run lambda { |env|
              request = Rack::Request.new(env)
              if RackApplication.valid_thrift_request?(request)
                RackApplication.successful_request(request, processor, protocol_factory)
              else
                RackApplication.failed_request
              end
            }
          end
        end
      end

      def self.successful_request(rack_request, processor, protocol_factory)
        response = Rack::Response.new([], 200, {'Content-Type' => THRIFT_HEADER})
        transport = IOStreamTransport.new rack_request.body, response
        protocol = protocol_factory.get_protocol transport
        processor.process protocol, protocol
        response
      end

      def self.failed_request
        Rack::Response.new(['Not Found'], 404, {'Content-Type' => THRIFT_HEADER})
      end

      def self.valid_thrift_request?(rack_request)
        rack_request.post? &&
          rack_request.env["CONTENT_TYPE"] == THRIFT_HEADER &&
          rack_request.env['CONTENT_LENGTH'].to_i > 0
      end
    end
  end
end

