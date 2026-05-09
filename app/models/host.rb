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
  has_and_belongs_to_many :ips
  before_create :check_params
  belongs_to :infrastructure
  belongs_to :environment
  belongs_to :host_type

  validates :name, uniqueness: true, presence: true

  # Comma-separated IP addresses (no HTML). Use +host_linked_ip_addresses_markup(host)+ in views for anchor links.
  def all_ips
    ips.order(:address).pluck(:address).join(', ')
  end

  def all_ips_except_this(ip_to_exclude)
    ips.where.not(address: ip_to_exclude).order(:address).pluck(:address).join(', ')
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

end
