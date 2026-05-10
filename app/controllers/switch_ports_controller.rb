# frozen_string_literal: true

class SwitchPortsController < ApplicationController
  before_action :set_network_switch
  before_action :set_switch_port, only: [:edit, :update, :destroy]
  before_action :authenticate_admin!

  def new
    @page_title = (Setting.find_by(name: "WebsiteName")&.value || "IP Planning") + " - " + I18n.t("switch_ports") + " - " + I18n.t("adding_switch_port")
    @switch_port = @network_switch.switch_ports.build
  end

  def create
    @switch_port = @network_switch.switch_ports.build(switch_port_params)

    if @switch_port.save
      redirect_to @network_switch, notice: t("switch_port_was_successfully_created")
    else
      @page_title = (Setting.find_by(name: "WebsiteName")&.value || "IP Planning") + " - " + I18n.t("switch_ports") + " - " + I18n.t("adding_switch_port")
      render :new
    end
  end

  def edit
    @page_title = (Setting.find_by(name: "WebsiteName")&.value || "IP Planning") + " - " + I18n.t("switch_ports") + " - " + I18n.t("editing_switch_port")
  end

  def update
    if @switch_port.update(switch_port_params)
      redirect_to @network_switch, notice: t("switch_port_was_successfully_updated")
    else
      @page_title = (Setting.find_by(name: "WebsiteName")&.value || "IP Planning") + " - " + I18n.t("switch_ports") + " - " + I18n.t("editing_switch_port")
      render :edit
    end
  end

  def destroy
    @switch_port.destroy
    redirect_to @network_switch, notice: t("switch_port_was_successfully_destroyed")
  end

  private

  def set_network_switch
    @network_switch = NetworkSwitch.find(params[:network_switch_id])
  end

  def set_switch_port
    @switch_port = @network_switch.switch_ports.find(params[:id])
  end

  def switch_port_params
    params.require(:switch_port).permit(:name)
  end
end
