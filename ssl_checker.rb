#!/usr/bin/env ruby
require "socket"
require "openssl"

# Simple helper class to verify to check whether a domain's SSL certificate has expired
class SSLChecker

  # PUBLIC
  # Ensures that the SSL certificate for a suppied hostname and port hasn't expired
  # hostname - the FQDN hostname for the server you wish to query
  # port - the port on which the SSL certificate is being served (usually 443 for https)
  #
  # returns an error code of 1 for an expired certificate, else returns code 0 (success)
  # 
  # e.g. SSLChecker.check('www.example.com', 443)
  def self.check(hostname, port)
    tcp_client = TCPSocket.new(hostname, port)
    ssl_client = OpenSSL::SSL::SSLSocket.new(tcp_client)
    ssl_client.hostname = hostname
    ssl_client.connect
    cert = OpenSSL::X509::Certificate.new(ssl_client.peer_cert)
    ssl_client.sysclose
    tcp_client.close

    if Time.now > cert.not_after
      puts "FAIL: Certificate Expired #{cert.not_after}"
    else
      puts "PASS: Certificate Expires #{cert.not_after}"
    end
  end
end

# Entrypoint
# ssl_checker.rb 'www.example.com', 443
if __FILE__ == $0
  hostname, port = ARGV
  SSLChecker.check(hostname, port)
end

# Credit: https://gist.github.com/matiaskorhonen/81b87ede6af1704c67b8
