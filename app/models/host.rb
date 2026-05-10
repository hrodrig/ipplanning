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
class Host < ApplicationRecord
  DEPLOYMENT_FORMS = %w[cloud_vm rack_mount tower desktop shelf other].freeze
  RACK_MOUNT = "rack_mount"

  has_and_belongs_to_many :ips
  before_create :check_params
  belongs_to :infrastructure
  belongs_to :environment
  belongs_to :host_type
  belongs_to :server_rack, optional: true

  after_initialize -> { self.deployment_form ||= "other" }, if: :new_record?

  before_validation :clear_rack_fields_unless_rack_mount

  validates :name, uniqueness: true, presence: true
  validates :deployment_form, inclusion: { in: DEPLOYMENT_FORMS }
  validates :server_rack_id, presence: true, if: :rack_mount?
  validates :rack_units,
    numericality: { only_integer: true, greater_than_or_equal_to: 1 },
    presence: true,
    if: :rack_mount?
  validates :rack_position_start,
    numericality: { only_integer: true, greater_than_or_equal_to: 1, allow_nil: true }

  def self.deployment_form_select_options
    DEPLOYMENT_FORMS.map { |key| [I18n.t("host_deployment_#{key}"), key] }
  end

  def rack_mount?
    deployment_form == RACK_MOUNT
  end

  def deployment_form_label
    return "" if deployment_form.blank?

    I18n.t("host_deployment_#{deployment_form}", default: deployment_form.humanize)
  end

  # Comma-separated IP addresses (no HTML). Use +host_linked_ip_addresses_markup(host)+ in views for anchor links.
  def all_ips
    ips.order_by_ipv4_address.pluck(:address).join(', ')
  end

  def all_ips_except_this(ip_to_exclude)
    ips.where.not(address: ip_to_exclude).order_by_ipv4_address.pluck(:address).join(', ')
  end

  def other_ips(exclude_this)
    ips = self.ips
    array_ips = []
    if ips.count > 0
      ips.each do |ip|
        if ip.address != exclude_this
          array_ips << ip
        end
      end
    end
    return array_ips
  end

  def check_params
   self.name.downcase!
 end

  def clear_rack_fields_unless_rack_mount
    return if rack_mount?

    self.server_rack_id = nil
    self.rack_units = nil
    self.rack_position_start = nil
  end

end
