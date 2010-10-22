require 'casclient'
require 'casclient/frameworks/rails/filter'

CASClient::Frameworks::Rails::Filter.configure(
  :cas_base_url => "https://login.xtreme.se/",
  :username_session_key => :cas_login,
  :proxy_callback_url =>  "https://proxy_login.xtreme.se/cas_proxy_callback/receive_pgt",
  :proxy_retrieval_url => "https://proxy_login.xtreme.se/cas_proxy_callback/retrieve_pgt",  
  :use_gatewaying => false,
  :logger => Rails.logger  
)
