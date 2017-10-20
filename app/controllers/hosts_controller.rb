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
class HostsController < ApplicationController
  before_action :set_host, only: [:show, :edit, :update, :destroy, :add_ip_to_host, :create_ip_to_host, :destroy_ip_from_host]
  before_action :authenticate_admin!

  # GET /hosts
  # GET /hosts.json
  def index
    @page_title = Setting.find_by_name('WebsiteName').value + ' - ' + I18n.t('hosts')
    @hosts = Host.all.order(:name)
  end

  # GET /hosts/1
  # GET /hosts/1.json
  def show
    @page_title = Setting.find_by_name('WebsiteName').value + ' - ' + I18n.t('hosts') + ' - ' + @host.name
  end

  # GET /hosts/new
  def new
    @page_title = Setting.find_by_name('WebsiteName').value + ' - ' + I18n.t('hosts') + ' - ' + I18n.t('adding_host')
    @host = Host.new
  end

  # GET /hosts/1/edit
  def edit
    @page_title = Setting.find_by_name('WebsiteName').value + ' - ' + I18n.t('hosts') + ' - ' + @host.name + ' - ' + I18n.t('editing_host')
  end

  # POST /hosts
  # POST /hosts.json
  def create
    @host = Host.new(host_params)
    @host.name = @host.name.downcase

    respond_to do |format|
      if @host.save
        format.html { redirect_to @host, notice: I18n.t('host_created') }
        format.json { render :show, status: :created, location: @host }
      else
        format.html { render :new }
        format.json { render json: @host.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /hosts/1
  # PATCH/PUT /hosts/1.json
  def update
    respond_to do |format|
      if @host.update(host_params)
        @host.name = @host.name.downcase
        @host.save
        format.html { redirect_to @host, notice: I18n.t('host_updated') }
        format.json { render :show, status: :ok, location: @host }
      else
        format.html { render :edit }
        format.json { render json: @host.errors, status: :unprocessable_entity }
      end
    end
  end

  def add_ip_to_host
    @ip = Ip.new
  end

  def create_ip_to_host
    @ip = Ip.find_by(address: params[:ip][:address])
    respond_to do |format|
      if @ip.present? and (@ip.is_reserved != true)
        @host.ips << @ip
        format.html { redirect_to @host, notice: I18n.t('host_ip_address_created') }
        format.json { render :show, status: :created, location: @host }
      else
        @ip = Ip.new
        format.html { render :add_ip_to_host }
        format.json { render json: @host.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy_ip_from_host
    @host.ips.delete(params[:ip_id])
    respond_to do |format|
      format.html { redirect_to @host, notice: I18n.t('host_ip_address_destroyed') }
      format.json { head :no_content }
    end
  end

  # DELETE /hosts/1
  # DELETE /hosts/1.json
  def destroy
    @host.destroy
    respond_to do |format|
      format.html { redirect_to hosts_url, notice: I18n.t('host_destroyed') }
      format.json { head :no_content }
    end
  end

  private

  def set_host
    @host = Host.find(params[:id])
  end

  def host_params
    params.require(:host).permit(:name, :description, :infraestructure_id,
      :environment_id, :host_type_id, :memory_size, :total_sockets, :total_vcpus)
  end

  def ip_params
    params.require(:ip).permit(:address)
  end

end
