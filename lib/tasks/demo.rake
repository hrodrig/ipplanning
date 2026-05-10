# frozen_string_literal: true

namespace :demo do
  desc "Delete hosts, IPs, VLANs, taxonomy, settings, admins, users, external IPs, and Active Storage rows. Requires DEMO_RESET_ALLOWED=1 outside development/test."
  task purge: :environment do
    Demo::Populator.purge!
    AppSettings.clear_cache!
  end

  desc "Load the demo dataset (expects an empty DB; run demo:reset instead for a full refresh)."
  task populate: :environment do
    Demo::Populator.new.populate!
    AppSettings.clear_cache!
  end

  desc "Purge then populate demo data. Use on scheduled demo sandboxes. Set DEMO_RESET_ALLOWED=1 in production/staging."
  task reset: :environment do
    Demo::Populator.reset!
  end
end
