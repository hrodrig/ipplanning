# frozen_string_literal: true

class ServerRacksController < ApplicationController
  before_action :set_server_rack, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_admin!

  def index
    @page_title = (Setting.find_by(name: "WebsiteName")&.value || "IP Planning") + " - " + I18n.t("server_racks")
    @server_racks = ServerRack.joins(:location).includes(:location).order("locations.name ASC", "server_racks.name ASC")
  end

  def show
    @page_title = (Setting.find_by(name: "WebsiteName")&.value || "IP Planning") + " - " + I18n.t("server_racks") + " - " + @server_rack.name
    @rack_diagram_highlight_host = nil
    if params[:highlight_host_id].present?
      candidate = Host.find_by(id: params[:highlight_host_id])
      if candidate&.server_rack_id == @server_rack.id && candidate.rack_mount?
        @rack_diagram_highlight_host = candidate
      end
    end
    @rack_diagram_highlight_network_switch = nil
    if params[:highlight_network_switch_id].present?
      candidate = NetworkSwitch.find_by(id: params[:highlight_network_switch_id])
      if candidate&.server_rack_id == @server_rack.id
        @rack_diagram_highlight_network_switch = candidate
      end
    end
  end

  def new
    @page_title = (Setting.find_by(name: "WebsiteName")&.value || "IP Planning") + " - " + I18n.t("server_racks") + " - " + I18n.t("adding_server_rack")
    @server_rack = ServerRack.new(location_id: params[:location_id])
  end

  def edit
    @page_title = (Setting.find_by(name: "WebsiteName")&.value || "IP Planning") + " - " + I18n.t("server_racks") + " - " + @server_rack.name + " - " + I18n.t("editing_server_rack")
  end

  def create
    @server_rack = ServerRack.new(server_rack_params)

    respond_to do |format|
      if @server_rack.save
        format.html { redirect_to @server_rack, notice: t("server_rack_was_successfully_created") }
        format.json { render :show, status: :created }
      else
        format.html { render :new }
        format.json { render json: @server_rack.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @server_rack.update(server_rack_params)
        format.html { redirect_to @server_rack, notice: t("server_rack_was_successfully_updated") }
        format.json { render :show, status: :ok }
      else
        format.html { render :edit }
        format.json { render json: @server_rack.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    rack_name = @server_rack.name
    host_count = @server_rack.hosts.count
    switch_count = @server_rack.network_switches.count
    if @server_rack.destroy
      respond_to do |format|
        format.html { redirect_to server_racks_url, notice: t("server_rack_was_successfully_destroyed") }
        format.json { head :no_content }
      end
    else
      msg = if host_count.positive?
        t("server_rack_destroy_blocked_hosts", name: rack_name, count: host_count)
      elsif switch_count.positive?
        t("server_rack_destroy_blocked_network_switches", name: rack_name, count: switch_count)
      else
        @server_rack.errors.full_messages.to_sentence.presence || t("server_rack_cannot_be_destroyed", name: rack_name)
      end
      respond_to do |format|
        format.html { redirect_to server_racks_url, alert: msg }
        format.json { render json: { errors: @server_rack.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_server_rack
    @server_rack = ServerRack.includes(network_switches: :switch_ports).find(params[:id])
  end

  def server_rack_params
    params.require(:server_rack).permit(:location_id, :name, :u_height, :notes, photos: [])
  end
end
