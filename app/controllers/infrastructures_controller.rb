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
class InfrastructuresController < ApplicationController
  before_action :set_infrastructure, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_admin!

  # GET /infrastructures
  # GET /infrastructures.json
  def index
    @page_title = (Setting.find_by(name: 'WebsiteName')&.value || "IP Planning") + ' - ' + I18n.t('infrastructures')
    @infrastructures = Infrastructure.all
  end

  # GET /infrastructures/1
  # GET /infrastructures/1.json
  def show
    @page_title = (Setting.find_by(name: 'WebsiteName')&.value || "IP Planning") + ' - ' + I18n.t('infrastructures') + ' - ' + @infrastructure.name
  end

  # GET /infrastructures/new
  def new
    @page_title = (Setting.find_by(name: 'WebsiteName')&.value || "IP Planning") + ' - ' + I18n.t('infrastructures') + ' - ' + I18n.t('adding_infrastructure')
    @infrastructure = Infrastructure.new
  end

  # GET /infrastructures/1/edit
  def edit
    @page_title = (Setting.find_by(name: 'WebsiteName')&.value || "IP Planning") + ' - ' + I18n.t('infrastructures') + ' - ' + @infrastructure.name + ' - ' + I18n.t('editing_infrastructure')
  end

  # POST /infrastructures
  # POST /infrastructures.json
  def create
    @infrastructure = Infrastructure.new(infrastructure_params)

    respond_to do |format|
      if @infrastructure.save
        format.html { redirect_to @infrastructure, notice: t('infrastructure_was_successfully_created') }
        format.json { render :show, status: :created, location: @infrastructure }
      else
        format.html { render :new }
        format.json { render json: @infrastructure.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /infrastructures/1
  # PATCH/PUT /infrastructures/1.json
  def update
    respond_to do |format|
      if @infrastructure.update(infrastructure_params)
        format.html { redirect_to @infrastructure, notice: t('infrastructure_was_successfully_updated') }
        format.json { render :show, status: :ok, location: @infrastructure }
      else
        format.html { render :edit }
        format.json { render json: @infrastructure.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /infrastructures/1
  # DELETE /infrastructures/1.json
  def destroy
    @infrastructure.destroy
    respond_to do |format|
      format.html { redirect_to infrastructures_url, notice: t('infrastructure_was_successfully_destroyed') }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_infrastructure
      @infrastructure = Infrastructure.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def infrastructure_params
      params.require(:infrastructure).permit(:name, :description)
    end
end
