module SslConfig
  #contains constants for certificate used for SSL
  #
  USE_SSL = true
  #SERVER_KEY_PATH_ = "cert/composer.key"
  #SERVER_CERT_PATH_ = "cert/composer.crt"
  SERVER_KEY_PATH_ = "cert/ca/LeadLab_root_cert_TEST.pem"
  SERVER_CERT_PATH_ = "cert/ca/LeadLab_root_cert_TEST.pem"
  #
  #CLIENT_KEY_PATH = "cert/client.key"
  #CLIENT_CERT_PATH = "cert/client.crt"
  CLIENT_KEY_PATH = "cert/ca/LeadLab_root_cert_TEST.pem"
  CLIENT_CERT_PATH = "cert/ca/LeadLab_root_cert_TEST.pem"
  #
  #SERVER_KEY_ = OpenSSL::PKey::RSA.new(File.open(SERVER_KEY_PATH_).read)
  #SERVER_CERT_ = OpenSSL::X509::Certificate.new(File.open(SERVER_CERT_PATH_).read)
  #
  CLIENT_KEY = OpenSSL::PKey::RSA.new(File.open(CLIENT_KEY_PATH).read)
  CLIENT_CERT = OpenSSL::X509::Certificate.new(File.open(CLIENT_CERT_PATH).read)

  def self.getUseSsl
    USE_SSL
  end

  def self.getServerKeyPath
    SERVER_KEY_PATH_
  end

  def self.getServerCertPath
    SERVER_CERT_PATH_
  end

  def self.getClientKeyPath
    CLIENT_KEY_PATH
  end

  def self.getClientCertPath
    CLIENT_CERT_PATH
  end
end
