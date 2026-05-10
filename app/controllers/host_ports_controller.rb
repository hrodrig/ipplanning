# frozen_string_literal: true

class HostPortsController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_host
  before_action :set_host_port, only: %i[edit update destroy]

  def new
    @host_port = @host.host_ports.build(port_kind: "physical")
  end

  def create
    @host_port = @host.host_ports.build(host_port_params)
    if @host_port.save
      redirect_to @host, notice: t("host_port_created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @host_port.update(host_port_params)
      redirect_to @host, notice: t("host_port_updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @host_port.destroy
    redirect_to @host, notice: t("host_port_destroyed")
  end

  private

  def set_host
    @host = Host.find(params[:host_id])
  end

  def set_host_port
    @host_port = @host.host_ports.find(params[:id])
  end

  def host_port_params
    params.require(:host_port).permit(:name, :port_kind, :mac_address, :notes)
  end
end
