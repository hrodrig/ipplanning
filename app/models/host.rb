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
  belongs_to :infraestructure
  belongs_to :environment
  belongs_to :host_type

  validates :name, uniqueness: true, presence: true

  def all_ips
    ips = self.ips
    string_de_ips = ''
    if ips.count > 0
      array_of_ips = []
      ips.each do |ip|
        array_of_ips << '<a href="#'+ip.address+'">'+ip.address+'</a>'
      end
      if array_of_ips.count > 0
        string_de_ips = array_of_ips.join ', '
      end
      return string_de_ips
    else
      return ''
    end
  end

  def all_ips_except_this(ip_to_exclude)
    ips = self.ips
    string_de_ips = ''
    if ips.count > 0
      array_of_ips = []
      ips.each do |ip|
        if ip.address != ip_to_exclude
          array_of_ips << '<a href="#'+ip.address+'">'+ip.address+'</a>'
        end
      end
      if array_of_ips.count > 0
        string_de_ips = array_of_ips.join ', '
      end
      return string_de_ips
    else
      return ''
    end
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
