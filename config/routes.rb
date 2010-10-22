CasProxy::Application.routes.draw do
  match 'cas_proxy_callback/:action', :to => "cas_proxy_callback", :as => "cas_proxy_callback"
end
