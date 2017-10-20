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
class Ip < ApplicationRecord
  belongs_to :vlan
  has_and_belongs_to_many :hosts, dependent: :destroy
  validates :address, uniqueness: true, presence: true
  validates :hostname_alias, uniqueness: true, if: :hostname_alias?

  def hostname
    if self.host.present?
      '<a href="/hosts/'+self.host.id.to_s+'">'+self.host.name + '</a>'
    else
      ''
    end
  end

  def hostname_with_descriptor
    if self.is_reserved?
      return I18n.t('reserved')
    end
    if self.hostname_alias.present?
      return self.long_hostname
    end
    if self.host.present?
      '<a href="/hosts/'+self.host.id.to_s+'">'+ self.text_hostname_with_descriptor + '</a>'
    else
      ''
    end
  end

  def text_hostname_with_descriptor
    if self.is_reserved?
      return I18n.t('reserved')
    end
    if self.host.present?
      visual_hostname = self.long_hostname
      if self.hostname_alias.present?
        visual_hostname = self.hostname_alias
      end
      visual_hostname
    else
      ''
    end
  end

  def short_hostname
    if self.is_reserved?
      return I18n.t('reserved').downcase
    end
    if self.host.present?
      if self.vlan.descriptor.present? and self.use_vlan_descriptor?
        return self.host.name + "-#{self.vlan.descriptor}"
      else
        if self.hostname_alias.present?
          return self.hostname_alias
        else
          return self.host.name
        end
      end
    end
    if self.hostname_alias.present? and self.host.nil?
      if self.vlan.descriptor.present? and self.use_vlan_descriptor?
        return self.hostname_alias + "-#{self.vlan.descriptor}"
      else
        return self.hostname_alias
      end
    end
  end

  def long_hostname
    if self.is_reserved?
      str_hostname =  ''
      ip_address = self.address
      dotted_ip_address = ip_address.gsub('.','-')
      str_hostname = I18n.t('reserved').downcase+'-'+dotted_ip_address
      if self.use_vlan_descriptor?
        if self.vlan.descriptor.present?
          str_hostname = str_hostname + "-#{self.vlan.descriptor}"
        end
      end
      if self.use_domain_name.present?
        str_hostname = str_hostname + ".#{Setting.find_by_name('DomainName').value}"
      end
      return str_hostname
    end
    if self.hostname_alias.present? and self.host.nil?
      if self.use_domain_name.present?
        str_hostname = self.hostname_alias + ".#{Setting.find_by_name('DomainName').value}"
      else
        str_hostname =  self.complete_hostname_alias
      end
      if self.vlan.descriptor.present? and self.use_vlan_descriptor?
        return str_hostname + "-#{self.vlan.descriptor}"
      else
        return str_hostname
      end
    end

    if self.host.present?
      if self.use_domain_name.present?
        return self.short_hostname + ".#{Setting.find_by_name('DomainName').value}"
      else
        if self.hostname_alias.present?
          return self.complete_hostname_alias
        else
          return self.short_hostname
        end
      end
    end
  end

  def host
    if self.hosts.count > 0
      self.hosts.first
    end
  end

  def self.used_ips
    ips = Ip.all
    used_ips_address = 0
    ips.each do |ip|
      if ip.host.present?
        used_ips_address+= 1
      end
    end
    return used_ips_address.to_s
  end

  def self.generate_etc_hosts
    etc_hosts = ''
    separator = "#-----------------------------------------------------------------------------------------\n"
    etc_hosts << separator
    line = "# /etc/hosts file generated by ip-planning system at #{Time.now.to_s}\n"
    etc_hosts << line
    etc_hosts << separator

    Vlan.order(:number).each do |vlan|

      if vlan.include_in_etc_hosts?
        etc_hosts << separator
        line = "# Vlan Name: #{vlan.name}\n"
        etc_hosts << line
        line = "# Vlan ID: #{vlan.number}\r# Network: #{vlan.network}/#{vlan.netmask}\r# Gateway: #{vlan.gateway}\n"
        etc_hosts << line
        etc_hosts << separator
      end

      vlan.ips.order(:address).each do |ip|

        if ip.include_in_etc_hosts.nil? and !ip.is_reserved
          puts "Skipping ip adddress: #{ip.address}"
          next
        else
          if  ip.host.present? or ip.hostname_alias.present?
            line = "#{ip.address}\t#{ip.long_hostname}\t#{ip.short_hostname}\n"
            etc_hosts << line
          else
            puts "Skipping empty ip adddress: #{ip.address}"
          end
        end
      end
    end

    etc_hosts << separator
    line = "# External Ip Address\n"
    etc_hosts << line
    Externalip.order(:address).each do |externalip|
      if externalip.include_in_etc_hosts.present?
        line = "#{externalip.address}\t#{externalip.hostname}\t#{externalip.short_hostname}\n"
        etc_hosts << line
      else
        next
      end
    end

    return etc_hosts
  end

end
