require 'logger'
require "socket"
require "openssl"
require "thread"

module Net
    class HTTP < Protocol
        module Server
            class SslServer
                # Default host to bind to.
                DEFAULT_HOST = '0.0.0.0'

                # Default port to listen on.
                DEFAULT_PORT = 443

                def initialize(options)
                    log = options.fetch(:log, $stderr)
                    @logger = Logger.new(log)

                    sslContext = OpenSSL::SSL::SSLContext.new
                    sslContext.cert = OpenSSL::X509::Certificate.new(File.open(options[:certificate]))
                    sslContext.key = OpenSSL::PKey::RSA.new(File.open(options[:key]))

                    host = options.fetch(:host, DEFAULT_HOST)
                    port = options.fetch(:port, DEFAULT_PORT)
                    server = TCPServer.new(host, port)
                    @sslServer = OpenSSL::SSL::SSLServer.new(server, sslContext)

                    @background = options.fetch(:background, true)
                end

                def start
                    @server_thread = Thread.new {
                        start_reactor
                    }
                    unless @background
                        @server_thread.join
                    end
                end

                def join
                    unless @server_thread.nil?
                        @server_thread.join
                    end
                end

                private

                def start_reactor
                    loop {
                        socket = @sslServer.accept
                        Thread.new {
                            begin
                                serve(socket)
                            rescue Exception => e
                                @logger.warn(e)
                            end
                        }
                    }
                end
            end
        end
    end
end
