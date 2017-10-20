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
class InfraestructuresController < ApplicationController
  before_action :set_infraestructure, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_admin!

  # GET /infraestructures
  # GET /infraestructures.json
  def index
    @page_title = Setting.find_by_name('WebsiteName').value + ' - ' + I18n.t('infraestructures')
    @infraestructures = Infraestructure.all
  end

  # GET /infraestructures/1
  # GET /infraestructures/1.json
  def show
    @page_title = Setting.find_by_name('WebsiteName').value + ' - ' + I18n.t('infraestructures') + ' - ' + @infraestructure.name
  end

  # GET /infraestructures/new
  def new
    @page_title = Setting.find_by_name('WebsiteName').value + ' - ' + I18n.t('infraestructures') + ' - ' + I18n.t('adding_infraestructure')
    @infraestructure = Infraestructure.new
  end

  # GET /infraestructures/1/edit
  def edit
    @page_title = Setting.find_by_name('WebsiteName').value + ' - ' + I18n.t('infraestructures') + ' - ' + @infraestructure.name + ' - ' + I18n.t('editing_infraestructure')
  end

  # POST /infraestructures
  # POST /infraestructures.json
  def create
    @infraestructure = Infraestructure.new(infraestructure_params)

    respond_to do |format|
      if @infraestructure.save
        format.html { redirect_to @infraestructure, notice: t('infraestructure_was_successfully_created') }
        format.json { render :show, status: :created, location: @infraestructure }
      else
        format.html { render :new }
        format.json { render json: @infraestructure.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /infraestructures/1
  # PATCH/PUT /infraestructures/1.json
  def update
    respond_to do |format|
      if @infraestructure.update(infraestructure_params)
        format.html { redirect_to @infraestructure, notice: t('infraestructure_was_successfully_updated') }
        format.json { render :show, status: :ok, location: @infraestructure }
      else
        format.html { render :edit }
        format.json { render json: @infraestructure.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /infraestructures/1
  # DELETE /infraestructures/1.json
  def destroy
    @infraestructure.destroy
    respond_to do |format|
      format.html { redirect_to infraestructures_url, notice: t('infraestructure_was_successfully_destroyed') }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_infraestructure
      @infraestructure = Infraestructure.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def infraestructure_params
      params.require(:infraestructure).permit(:name, :description)
    end
end
