# frozen_string_literal: true

class LocationsController < ApplicationController
  before_action :set_location, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_admin!

  def index
    @page_title = (Setting.find_by(name: "WebsiteName")&.value || "IP Planning") + " - " + I18n.t("locations")
    @locations = Location.order(:name)
  end

  def show
    @page_title = (Setting.find_by(name: "WebsiteName")&.value || "IP Planning") + " - " + I18n.t("locations") + " - " + @location.name
  end

  def new
    @page_title = (Setting.find_by(name: "WebsiteName")&.value || "IP Planning") + " - " + I18n.t("locations") + " - " + I18n.t("adding_location")
    @location = Location.new
  end

  def edit
    @page_title = (Setting.find_by(name: "WebsiteName")&.value || "IP Planning") + " - " + I18n.t("locations") + " - " + @location.name + " - " + I18n.t("editing_location")
  end

  def create
    @location = Location.new(location_params)

    respond_to do |format|
      if @location.save
        format.html { redirect_to @location, notice: t("location_was_successfully_created") }
        format.json { render :show, status: :created, location: @location }
      else
        format.html { render :new }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @location.update(location_params)
        format.html { redirect_to @location, notice: t("location_was_successfully_updated") }
        format.json { render :show, status: :ok, location: @location }
      else
        format.html { render :edit }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @location.destroy
    respond_to do |format|
      format.html { redirect_to locations_url, notice: t("location_was_successfully_destroyed") }
      format.json { head :no_content }
    end
  end

  private

  def set_location
    @location = Location.find(params[:id])
  end

  def location_params
    params.require(:location).permit(:name, :description)
  end
end
