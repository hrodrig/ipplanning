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
class IpsController < ApplicationController
  before_action :set_ip, only: [:show, :edit, :update, :destroy, :add_host_to_ip, :create_host_to_ip]
  before_action :authenticate_admin!

  # GET /ips
  # GET /ips.json
  def index
    @page_title = Setting.find_by_name('WebsiteName').value + ' - ' + I18n.t('ips')
    @vlans = Vlan.all.order(:number)
    @ips = Ip.all.order(:number)
    @orphaned_ips = Ip.where(vlan_id: nil)
  end

  # GET /ips/1
  # GET /ips/1.json
  def show
    @page_title = Setting.find_by_name('WebsiteName').value + ' - ' + I18n.t('ips') + ' - ' + @ip.address
  end

  # # GET /ips/new
  # def new
  #   @page_title = Setting.find_by_name('WebsiteName').value + ' - ' + I18n.t('ips') + ' - ' + I18n.t('adding_ip')
  #   @ip = Ip.new
  # end

  # GET /ips/1/edit
  def edit
    @page_title = Setting.find_by_name('WebsiteName').value + ' - ' + I18n.t('ips') + ' - ' + @ip.address + ' - ' + I18n.t('editing_ip')
  end

  # POST /ips
  # POST /ips.json
  def create
    @ip = Ip.new(ip_params)

    respond_to do |format|
      if @ip.save
        format.html { redirect_to ips_path, notice: I18n.t('ip_address_created') }
        format.json { render :show, status: :created, location: @ip }
      else
        format.html { render :new }
        format.json { render json: @ip.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ips/1
  # PATCH/PUT /ips/1.json
  def update
    respond_to do |format|
      if @ip.update(ip_params)
        format.html { redirect_to @ip, notice: I18n.t('ip_address_updated') }
        format.json { render :show, status: :ok, location: @ip }
      else
        format.html { render :edit }
        format.json { render json: @ip.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ips/1
  # DELETE /ips/1.json
  def destroy
    @ip.destroy
    respond_to do |format|
      format.html { redirect_to ips_url, notice: I18n.t('ip_address_destroyed') }
      format.json { head :no_content }
    end
  end

  def add_host_to_ip
    @host = Host.new
  end
  def create_host_to_ip
    respond_to do |format|
      if @ip.present?
        @host = Host.find_by(name: params[:host][:name])
        if !@host.present?
          @host = Host.create(host_params)
        end
        @host.ips << @ip
        @host.name = @host.name.downcase
        @host.save
        format.html { redirect_to @host, notice: I18n.t('ip_address_added_to_host') }
        format.json { render :show, status: :created, location: @host }
      else
        @host = Host.new
        format.html { render :add_host_to_ip }
        format.json { render json: @host.errors, status: :unprocessable_entity }
      end
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ip
      @ip = Ip.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ip_params
      params.require(:ip).permit(:number, :name, :network, :netmask, :gateway, :notes, :include_in_etc_hosts, :use_vlan_descriptor, :hostname_alias, :is_reserved, :complete_hostname_alias, :use_domain_name)
    end
    def host_params
      params.require(:host).permit(:name, :description)
    end
end
