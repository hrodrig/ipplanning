module ApplicationHelper
  def get_icon(status)
    if status == true
      image_tag 'on.png'
    else
      image_tag 'off.png'
    end
  end

  # Renders Ip#hostname_with_descriptor as plain text or a link to the host (no HTML in the model).
  def ip_hostname_with_descriptor_markup(ip)
    return "".html_safe if ip.nil?

    if ip.is_reserved? || ip.hostname_alias.present?
      ip.hostname_with_descriptor
    elsif ip.host.present?
      link_to(ip.hostname_with_descriptor, host_path(ip.host))
    else
      "".html_safe
    end
  end

  # Fragment links to other IPs on the same page (replaces Host#all_ips HTML strings).
  def host_linked_ip_addresses_markup(host, except_address: nil)
    return "".html_safe unless host

    scope = host.ips.order(:address)
    scope = scope.where.not(address: except_address) if except_address.present?
    parts = scope.map { |ip| link_to(ip.address, "##{ip.address}") }
    safe_join(parts, ", ")
  end
end
