# frozen_string_literal: true

# Correct IPv4 ordering (numeric octets) and a 32-bit sort key for tables / Stimulus.
module Ipv4AddressSortable
  extend ActiveSupport::Concern

  class_methods do
    # MySQL: numeric order. Other adapters: fall back to string order.
    def order_by_ipv4_address
      if connection.adapter_name.match?(/mysql/i)
        t = quoted_table_name
        col = connection.quote_column_name(:address)
        order(Arel.sql("INET_ATON(#{t}.#{col}) ASC"))
      else
        order(:address)
      end
    end
  end

  # Packed IPv4 for comparisons and data-sort attributes (0 if not a valid IPv4 string).
  def ipv4_sort_integer
    Ipv4AddressSortable.ipv4_string_to_integer(address)
  end

  def self.ipv4_string_to_integer(addr)
    parts = addr.to_s.split(".")
    return 0 unless parts.length == 4
    return 0 unless parts.all? { |p| p.match?(/\A(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\z/) }

    parts.map(&:to_i).inject(0) { |acc, oct| acc * 256 + oct }
  end
end
