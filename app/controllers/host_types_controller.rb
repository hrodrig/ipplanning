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
class HostTypesController < ApplicationController
  before_action :set_host_type, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_admin!

  # GET /host_types
  # GET /host_types.json
  def index
    @page_title = Setting.find_by_name('WebsiteName').value + ' - ' + I18n.t('host_types')
    @host_types = HostType.all.order(:name)
  end

  # GET /host_types/1
  # GET /host_types/1.json
  def show
    @page_title = Setting.find_by_name('WebsiteName').value + ' - ' + I18n.t('host_types') + ' - ' + @host_type.name
  end

  # GET /host_types/new
  def new
    @page_title = Setting.find_by_name('WebsiteName').value + ' - ' + I18n.t('host_types') + ' - ' + I18n.t('adding_host_type')
    @host_type = HostType.new
  end

  # GET /host_types/1/edit
  def edit
    @page_title = Setting.find_by_name('WebsiteName').value + ' - ' + I18n.t('host_types') + ' - ' + @host_type.name + ' - ' + I18n.t('editing_host_type')
  end

  # POST /host_types
  # POST /host_types.json
  def create
    @host_type = HostType.new(host_type_params)

    respond_to do |format|
      if @host_type.save
        format.html { redirect_to @host_type, notice: t('host_type_was_successfully_created') }
        format.json { render :show, status: :created, location: @host_type }
      else
        format.html { render :new }
        format.json { render json: @host_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /host_types/1
  # PATCH/PUT /host_types/1.json
  def update
    respond_to do |format|
      if @host_type.update(host_type_params)
        format.html { redirect_to @host_type, notice: t('host_type_was_successfully_updated') }
        format.json { render :show, status: :ok, location: @host_type }
      else
        format.html { render :edit }
        format.json { render json: @host_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /host_types/1
  # DELETE /host_types/1.json
  def destroy
    @host_type.destroy
    respond_to do |format|
      format.html { redirect_to host_types_url, notice: t('host_type_was_successfully_destroyed') }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_host_type
      @host_type = HostType.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def host_type_params
      params.require(:host_type).permit(:name, :description)
    end
end
