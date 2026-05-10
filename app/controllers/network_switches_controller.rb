# frozen_string_literal: true

class NetworkSwitchesController < ApplicationController
  before_action :set_network_switch, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_admin!

  def index
    @page_title = (Setting.find_by(name: "WebsiteName")&.value || "IP Planning") + " - " + I18n.t("network_switches")
    @network_switches = NetworkSwitch.includes(:server_rack, :switch_ports).order(:name)
  end

  def show
    @page_title = (Setting.find_by(name: "WebsiteName")&.value || "IP Planning") + " - " + I18n.t("network_switches") + " - " + @network_switch.name
    @switch_ports = @network_switch.switch_ports_ordered_for_display
  end

  def new
    @page_title = (Setting.find_by(name: "WebsiteName")&.value || "IP Planning") + " - " + I18n.t("network_switches") + " - " + I18n.t("adding_network_switch")
    @network_switch = NetworkSwitch.new(server_rack_id: params[:server_rack_id])
  end

  def edit
    @page_title = (Setting.find_by(name: "WebsiteName")&.value || "IP Planning") + " - " + I18n.t("network_switches") + " - " + @network_switch.name + " - " + I18n.t("editing_network_switch")
  end

  def create
    raw = params.require(:network_switch)
    port_count = raw[:port_count].to_s.strip.to_i
    port_name_template = raw[:default_port_name_template].to_s.strip
    @network_switch = NetworkSwitch.new(raw.except(:port_count, :default_port_name_template).permit(*network_switch_permitted_keys, photos: []))

    if port_count.negative? || port_count > NetworkSwitch::MAX_DEFAULT_PORTS
      @network_switch.errors.add(:base, t("network_switch_port_count_invalid", max: NetworkSwitch::MAX_DEFAULT_PORTS))
      render :new
      return
    end

    begin
      NetworkSwitch.transaction do
        @network_switch.save!
        @network_switch.create_default_ports!(port_count, name_template: port_name_template.presence)
      end
      redirect_to @network_switch, notice: t("network_switch_was_successfully_created")
    rescue ActiveRecord::RecordInvalid
      render :new
    rescue ArgumentError => e
      @network_switch.errors.add(:base, e.message)
      render :new
    end
  end

  def update
    if @network_switch.update(network_switch_params)
      redirect_to @network_switch, notice: t("network_switch_was_successfully_updated")
    else
      render :edit
    end
  end

  def destroy
    switch_name = @network_switch.name
    if @network_switch.destroy
      redirect_to network_switches_url, notice: t("network_switch_was_successfully_destroyed")
    else
      msg = @network_switch.errors.full_messages.to_sentence.presence || t("network_switch_cannot_be_destroyed", name: switch_name)
      redirect_to network_switches_url, alert: msg
    end
  end

  private

  def set_network_switch
    @network_switch =
      if action_name == "show"
        NetworkSwitch.includes(server_rack: [:hosts, :network_switches]).find(params[:id])
      else
        NetworkSwitch.find(params[:id])
      end
  end

  def network_switch_params
    params.require(:network_switch).permit(*network_switch_permitted_keys, photos: [])
  end

  def network_switch_permitted_keys
    %i[
      name
      serial
      equipment_model
      notes
      firmware_version
      firmware_updated_on
      management_username
      management_secret_hint
      server_rack_id
      rack_position_start
      rack_units
      pdu_reference
      outlet_reference
    ]
  end
end
