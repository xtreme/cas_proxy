require 'casclient'
require 'casclient/frameworks/rails/filter'

CASClient::Frameworks::Rails::Filter.configure(
  :server_name => "login_proxy.xtreme.se",
  :server_port => 444
)
