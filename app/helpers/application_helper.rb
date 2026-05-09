module ApplicationHelper
  # Unified admin form controls (Tailwind) — use on text_field, text_area, select, number_field.
  FORM_CONTROL_CLASS = [
    "block w-full rounded-lg border border-gray-300 bg-white px-3 py-2",
    "text-sm text-gray-900 shadow-sm",
    "placeholder:text-gray-400",
    "transition-colors",
    "focus:border-indigo-500 focus:outline-none focus:ring-2 focus:ring-indigo-500/25",
    "disabled:cursor-not-allowed disabled:bg-gray-50 disabled:text-gray-500"
  ].join(" ").freeze

  FORM_LABEL_CLASS = "block text-sm font-medium text-gray-700".freeze

  FORM_CHECKBOX_CLASS = [
    "h-4 w-4 shrink-0 rounded border-gray-300 text-indigo-600",
    "focus:ring-2 focus:ring-indigo-500/30"
  ].join(" ").freeze

  def form_control_class
    FORM_CONTROL_CLASS
  end

  def form_label_class
    FORM_LABEL_CLASS
  end

  def form_checkbox_class
    FORM_CHECKBOX_CLASS
  end

  # Native <select> needs extra right padding for the browser chevron.
  def form_select_class
    "#{FORM_CONTROL_CLASS} pr-10"
  end

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
