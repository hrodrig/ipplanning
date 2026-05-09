# frozen_string_literal: true

# Memoized reads of rows in +settings+ (see +Setting+). Invalidated on every +Setting+ commit
# so updates from the UI apply immediately without extra wiring per controller.
class AppSettings
  MUTEX = Mutex.new

  class << self
    def domain_name
      value("DomainName")
    end

    # Returns the stored value as a String (+""+ if missing).
    def value(name)
      MUTEX.synchronize do
        cache[name] ||= Setting.find_by(name: name)&.value.to_s
      end
    end

    def clear_cache!
      MUTEX.synchronize { cache.clear }
    end

    private

    def cache
      @cache ||= {}
    end
  end
end
