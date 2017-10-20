# IPPLANNING: Ip Address Management System
# Copyright (c) 2016-2017 Hermes Rodríguez, hejeroaz@gmail.com
#
# The MIT License (MIT)
#
# Copyright (c) 2014 Evan Wallace
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# ----------------------------------------------------------------------------
Rails.application.routes.draw do

  resources :settings
  resources :host_types
  resources :infraestructures
  resources :environments
  resources :externalips
  get "etc/hosts", :controller => "etchosts", :action => "index"
  get "etc/hosts/download", :controller => "etchosts", :action => "download", :as => :download_etc_hosts

  devise_for :admins
  devise_for :users
  resources :hosts

  delete "hosts/:id/:ip_id/destroy", :controller => "hosts", :action => "destroy_ip_from_host", :as => :destroy_ip_from_host
  get "hosts/:id/add_ip", :controller => "hosts", :action => "add_ip_to_host", :as => :add_ip_to_host
  post "hosts/:id/add_ip", :controller => "hosts", :action => "create_ip_to_host", :as => :create_ip_to_host

  resources :ips
  get "ips/:id/add_host", :controller => "ips", :action => "add_host_to_ip", :as => :add_host_to_ip
  post "ips/:id/add_host", :controller => "ips", :action => "create_host_to_ip", :as => :create_host_to_ip

  get "vlans/:id/generate_network", :controller => "vlans", :action => "generate_network", :as => :generate_network
  resources :vlans
  root 'welcome#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
