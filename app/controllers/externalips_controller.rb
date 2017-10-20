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
class ExternalipsController < ApplicationController
  before_action :set_externalip, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_admin!

  # GET /externalips
  # GET /externalips.json
  def index
    @page_title = Setting.find_by_name('WebsiteName').value + ' - ' + I18n.t('external_ips')
    @externalips = Externalip.all
  end

  # GET /externalips/1
  # GET /externalips/1.json
  def show
    @page_title = Setting.find_by_name('WebsiteName').value + ' - ' + I18n.t('external_ips') + ' - ' + @externalip.address
  end

  # GET /externalips/new
  def new
    @page_title = Setting.find_by_name('WebsiteName').value + ' - ' + I18n.t('external_ips') + ' - ' + I18n.t('adding_external_ip')
    @externalip = Externalip.new
  end

  # GET /externalips/1/edit
  def edit
    @page_title = Setting.find_by_name('WebsiteName').value + ' - ' + I18n.t('external_ips') + ' - ' + @externalip.address
  end

  # POST /externalips
  # POST /externalips.json
  def create
    @externalip = Externalip.new(externalip_params)

    respond_to do |format|
      if @externalip.save
        format.html { redirect_to @externalip, notice: t('externalip_was_successfully_created') }
        format.json { render :show, status: :created, location: @externalip }
      else
        format.html { render :new }
        format.json { render json: @externalip.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /externalips/1
  # PATCH/PUT /externalips/1.json
  def update
    respond_to do |format|
      if @externalip.update(externalip_params)
        format.html { redirect_to externalips_url, notice: t('externalip_was_successfully_updated') }
        format.json { render :show, status: :ok, location: @externalip }
      else
        format.html { render :edit }
        format.json { render json: @externalip.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /externalips/1
  # DELETE /externalips/1.json
  def destroy
    @externalip.destroy
    respond_to do |format|
      format.html { redirect_to externalips_url, notice: t('externalip_was_successfully_destroyed') }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_externalip
      @externalip = Externalip.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def externalip_params
      params.require(:externalip).permit(:address, :hostname, :short_hostname, :notes, :include_in_etc_hosts)
    end
end
