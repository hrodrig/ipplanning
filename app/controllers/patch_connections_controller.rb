# frozen_string_literal: true

class PatchConnectionsController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_host
  before_action :set_patch_connection, only: %i[edit update destroy]

  def new
    if @host.host_ports.empty?
      redirect_to @host, alert: t("host_ports_required_for_patch")
      return
    end
    @patch_connection = PatchConnection.new
    if params[:host_port_id].present?
      @patch_connection.host_port = @host.host_ports.find_by(id: params[:host_port_id])
    end
    @patch_connection.host_port ||= @host.host_ports.first
    load_switch_ports_for_form
  end

  def create
    permitted = patch_connection_params
    hp = @host.host_ports.find_by(id: permitted[:host_port_id])
    @patch_connection = PatchConnection.new(permitted.except(:host_port_id))
    @patch_connection.host_port = hp
    load_switch_ports_for_form
    if hp.nil?
      @patch_connection.errors.add(:host_port_id, :invalid)
      render :new, status: :unprocessable_entity
      return
    end
    if @patch_connection.save
      redirect_to @host, notice: t("patch_connection_created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    load_switch_ports_for_form
  end

  def update
    permitted = patch_connection_params
    hp = @host.host_ports.find_by(id: permitted[:host_port_id])
    if hp.nil?
      @patch_connection.errors.add(:host_port_id, :invalid)
      load_switch_ports_for_form
      render :edit, status: :unprocessable_entity
      return
    end
    @patch_connection.host_port = hp
    if @patch_connection.update(permitted.except(:host_port_id))
      redirect_to @host, notice: t("patch_connection_updated")
    else
      load_switch_ports_for_form
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @patch_connection.destroy
    redirect_to @host, notice: t("patch_connection_destroyed")
  end

  private

  def set_host
    @host = Host.find(params[:host_id])
  end

  def set_patch_connection
    @patch_connection = PatchConnection.joins(:host_port).where(host_ports: { host_id: @host.id }).find(params[:id])
  end

  def patch_connection_params
    params.require(:patch_connection).permit(:host_port_id, :switch_port_id, :label, :cable_color, :installed_on, :notes)
  end

  def load_switch_ports_for_form
    exclude = @patch_connection&.persisted? ? @patch_connection : nil
    @switch_ports_for_select = SwitchPort
      .selectable_for_patch_connection(exclude: exclude)
      .includes(:network_switch)
      .joins(:network_switch)
      .order("network_switches.name ASC, switch_ports.name ASC")
  end
end
