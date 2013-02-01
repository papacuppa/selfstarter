Selfstarter::Application.routes.draw do
  root :to => 'preorder#index'
  match '/preorder'               => 'preorder#index'
  match '/preorder/share/:uuid'   => 'preorder#share', :via => :get
  match '/preorder/ipn'           => 'preorder#ipn', :via => :post
  match '/preorder/prefill'       => 'preorder#prefill'
  match '/preorder/postfill'      => 'preorder#postfill'
  
  get 'preorder/checkout'
  get 'preorder/confirm'
end
