# frozen_string_literal: true

module SettingsHelper
  MASKED_SETTING_NAMES = %w[BasicAuthPassword].freeze

  def setting_value_display(setting)
    if MASKED_SETTING_NAMES.include?(setting.name) && setting.value.present?
      content_tag(:span, class: "inline-flex flex-wrap items-center gap-x-2 gap-y-1") do
        safe_join([
          tag.span("•" * 8, class: "font-mono text-sm text-gray-500 tracking-[0.35em] select-none"),
          tag.span(t("settings_value_masked"), class: "text-xs text-gray-400")
        ])
      end
    elsif setting.value.blank?
      tag.span(t("settings_no_value"), class: "text-sm text-gray-400 italic")
    else
      tag.span(setting.value, class: "text-sm text-gray-900 font-mono break-all")
    end
  end

  def setting_description_display(setting)
    d = setting.description.to_s.strip
    if d.blank?
      tag.span(t("settings_no_description"), class: "text-sm text-gray-400 italic")
    else
      tag.span(d, class: "text-sm text-gray-600 leading-relaxed")
    end
  end

  def setting_row_kind(setting)
    return :security if setting.name.to_s.start_with?("BasicAuth")
    :default
  end

  # JSON responses must not expose secrets when listing settings.
  def setting_value_for_json(setting)
    if MASKED_SETTING_NAMES.include?(setting.name) && setting.value.present?
      "[masked]"
    else
      setting.value
    end
  end
end
