#contains constants for certificate used for SSL
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
SERVER_KEY = OpenSSL::PKey::RSA.new(File.open(SERVER_KEY_PATH_).read)
SERVER_CERT = OpenSSL::X509::Certificate.new(File.open(SERVER_CERT_PATH_).read)
#
CLIENT_KEY = OpenSSL::PKey::RSA.new(File.open(CLIENT_KEY_PATH).read)
CLIENT_CERT = OpenSSL::X509::Certificate.new(File.open(CLIENT_CERT_PATH).read)
