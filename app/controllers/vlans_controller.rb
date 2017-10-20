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
class VlansController < ApplicationController
  before_action :set_vlan, only: [:show, :edit, :update, :destroy, :generate_network]
  before_action :authenticate_admin!

  # GET /vlans
  # GET /vlans.json
  def index
    @page_title = Setting.find_by_name('WebsiteName').value + ' - ' + I18n.t('vlans')
    @vlans = Vlan.all.order(:number)
  end

  # GET /vlans/1
  # GET /vlans/1.json
  def show
    @page_title = Setting.find_by_name('WebsiteName').value + ' - ' + I18n.t('vlans') + ' - ' + @vlan.name
    @vlans = Vlan.all.order(:number)
  end

  # GET /vlans/new
  def new
    @page_title = Setting.find_by_name('WebsiteName').value + ' - ' + I18n.t('vlans') + ' - ' + I18n.t('add_vlan')
    @vlan = Vlan.new
  end

  # GET /vlans/1/edit
  def edit
    @page_title = Setting.find_by_name('WebsiteName').value + ' - ' + I18n.t('vlans') + ' - ' + @vlan.name + ' - ' + I18n.t('editing_vlan')
  end

  # POST /vlans
  # POST /vlans.json
  def create
    @vlan = Vlan.new(vlan_params)

    respond_to do |format|
      if @vlan.save
        format.html { redirect_to @vlan, notice: t('vlan_was_successfully_created') }
        format.json { render :show, status: :created, location: @vlan }
      else
        format.html { render :new }
        format.json { render json: @vlan.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /vlans/1
  # PATCH/PUT /vlans/1.json
  def update
    respond_to do |format|
      if @vlan.update(vlan_params)
        format.html { redirect_to @vlan, notice: t('vlan_was_successfully_updated') }
        format.json { render :show, status: :ok, location: @vlan }
      else
        format.html { render :edit }
        format.json { render json: @vlan.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vlans/1
  # DELETE /vlans/1.json
  def destroy
    @vlan.destroy
    respond_to do |format|
      format.html { redirect_to vlans_url, notice: t('vlan_was_successfully_destroyed') }
      format.json { head :no_content }
    end
  end

  def generate_network
    ip = IPAddress "#{@vlan.network}/#{@vlan.netmask}"
    net = ip.network
    ip.each_host do |ip_address|
      @vlan.ips.create(address: ip_address)
    end
    respond_to do |format|
      format.html { redirect_to vlans_url, notice: t('vlan_network_segment_was_created') }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vlan
      @vlan = Vlan.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def vlan_params
      params.require(:vlan).permit(:number, :name, :descriptor, :network, :netmask, :gateway, :notes, :include_in_etc_hosts)
    end
end
