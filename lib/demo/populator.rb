# frozen_string_literal: true

require "ipaddress"

module Demo
  # Wipes application data and reloads a rich dataset for public demo / QA sandboxes.
  # Destructive: never run against a production database unless explicitly allowed (see +.allowed?+).
  class Populator
    DEFAULT_ADMIN_EMAIL = "demo-admin@demo.ipplanning.local"
    DEFAULT_ADMIN_PASSWORD = "demo-demo-demo"

    class << self
      def allowed?
        Rails.env.local? || truthy?(ENV["DEMO_RESET_ALLOWED"])
      end

      def truthy?(value)
        %w[1 true yes on].include?(value.to_s.strip.downcase)
      end

      def reset!(io: $stdout)
        new(io: io).reset!
      end

      def purge!(io: $stdout)
        new(io: io).purge!
      end
    end

    def initialize(io: $stdout)
      @io = io
    end

    def reset!
      assert_allowed!
      ActiveRecord::Base.transaction do
        purge!
        populate!
      end
      AppSettings.clear_cache!
      log "Demo reset complete. Admin: #{admin_email} / password from ENV DEMO_ADMIN_PASSWORD or default (see README)."
    end

    def purge!
      assert_allowed!
      log "Purging data…"

      conn = ActiveRecord::Base.connection
      conn.execute("DELETE FROM hosts_ips") if conn.table_exists?("hosts_ips")

      if defined?(ActiveStorage) && conn.table_exists?("active_storage_attachments")
        ActiveStorage::Attachment.delete_all
        ActiveStorage::Blob.delete_all if conn.table_exists?("active_storage_blobs")
      end

      Ip.delete_all
      if conn.table_exists?("patch_connections")
        PatchConnection.delete_all
      end
      if conn.table_exists?("host_ports")
        HostPort.delete_all
      end
      Host.delete_all
      Externalip.delete_all
      Vlan.delete_all
      if conn.table_exists?("switch_ports")
        SwitchPort.delete_all
      end
      if conn.table_exists?("network_switches")
        NetworkSwitch.delete_all
      end
      ServerRack.delete_all
      Location.delete_all
      Environment.delete_all
      Infrastructure.delete_all
      HostType.delete_all
      User.delete_all
      Admin.delete_all
      Setting.delete_all

      log "Purge done."
    end

    def populate!
      # Caller may invoke after manual purge; still block accidental production writes.
      assert_allowed!

      domain = "demo.ipplanning.local"
      seed_settings!(domain)
      seed_admin!
      taxonomy = seed_taxonomy!
      vlans = seed_vlans!
      generate_all_ips!(vlans)
      seed_special_ips!(vlans, domain)
      seed_hosts!(vlans, taxonomy)
      seed_network_demo!(taxonomy)
      seed_externalips!(domain)

      log "Populate done (#{Ip.count} IPs, #{Host.count} hosts, #{Vlan.count} VLANs#{demo_network_suffix})."
    end

    private

    def assert_allowed!
      return if self.class.allowed?

      raise(
        "Demo reset refused: set DEMO_RESET_ALLOWED=1 (or run in development/test). " \
        "This task deletes almost all application data."
      )
    end

    def log(msg)
      @io.puts msg
    end

    def admin_email
      ENV.fetch("DEMO_ADMIN_EMAIL", DEFAULT_ADMIN_EMAIL)
    end

    def admin_password
      ENV.fetch("DEMO_ADMIN_PASSWORD", DEFAULT_ADMIN_PASSWORD)
    end

    def seed_settings!(domain)
      rows = [
        ["DomainName", domain, "Demo domain for generated hostnames"],
        ["WebsiteName", "IP Planning (Demo)", "Browser title and branding"],
        ["Brand", "IPPLANNING", "Brand label"],
        ["BrandMark", "", "Optional logo URL"],
        ["Footer", "Demo instance — data resets on a schedule. Do not store real inventory.", "Footer"],
        ["HeaderLeftImage", "", ""],
        ["HeaderCentralTitle", "", ""],
        ["HeaderRightImage", "", ""],
        ["BasicAuthRequired", "0", "HTTP basic for downloads off in demo"],
        ["BasicAuthUsername", "demo", ""],
        ["BasicAuthPassword", "demo", ""]
      ]
      now = Time.current
      rows.each do |name, value, description|
        Setting.create!(name: name, value: value, description: description, created_at: now, updated_at: now)
      end
    end

    def seed_admin!
      Admin.create!(
        email: admin_email,
        password: admin_password,
        password_confirmation: admin_password
      )
    end

    def seed_taxonomy!
      env_prod = Environment.create!(name: "Production", description: "Demo production tier")
      env_stg = Environment.create!(name: "Staging", description: "Demo staging tier")
      env_dev = Environment.create!(name: "Development", description: "Demo development tier")

      infra_vmware = Infrastructure.create!(name: "VMware", description: "On-prem virtualization")
      infra_aws = Infrastructure.create!(name: "AWS", description: "Cloud workloads")
      infra_bare = Infrastructure.create!(name: "Bare Metal", description: "Physical servers")

      ht_web = HostType.create!(name: "Web Server", description: "HTTP / application tier")
      ht_db = HostType.create!(name: "Database", description: "RDBMS / data tier")
      ht_lb = HostType.create!(name: "Load Balancer", description: "Traffic distribution")

      loc = Location.create!(name: "Demo DC East", description: "Fictitious colocation site")
      rack = ServerRack.create!(location: loc, name: "Rack-A1", u_height: 42, notes: "Demo rack for rack-mount hosts")

      {
        env_prod: env_prod, env_stg: env_stg, env_dev: env_dev,
        infra_vmware: infra_vmware, infra_aws: infra_aws, infra_bare: infra_bare,
        ht_web: ht_web, ht_db: ht_db, ht_lb: ht_lb,
        rack: rack
      }
    end

    def seed_vlans!
      small = Vlan.create!(
        number: 100,
        name: "Demo Lab (small)",
        network: "10.10.0.0",
        netmask: 28,
        gateway: "10.10.0.14",
        descriptor: "lab",
        notes: "Small subnet for quick browsing (≤64 IPs in one table block).",
        include_in_etc_hosts: true
      )
      large = Vlan.create!(
        number: 200,
        name: "Demo Campus (/24)",
        network: "10.20.0.0",
        netmask: 24,
        gateway: "10.20.0.254",
        descriptor: "prod",
        notes: "Large subnet to exercise collapsible IP chunks and search.",
        include_in_etc_hosts: true
      )
      medium = Vlan.create!(
        number: 300,
        name: "Demo WAN tail (/26)",
        network: "172.16.100.0",
        netmask: 26,
        gateway: "172.16.100.1",
        descriptor: "wan",
        notes: "Secondary segment; multi-homed host shares an IP here.",
        include_in_etc_hosts: true
      )
      { small: small, large: large, medium: medium }
    end

    def generate_all_ips!(vlans)
      vlans.each_value { |vlan| generate_ips_for_vlan!(vlan) }
    end

    def generate_ips_for_vlan!(vlan)
      block = IPAddress("#{vlan.network}/#{vlan.netmask}")
      block.each_host do |addr|
        vlan.ips.create!(address: addr.to_s)
      end
      gw = vlan.ips.find_by(address: vlan.gateway.to_s.strip)
      gw&.update!(is_default_gateway: true)
    end

    def seed_special_ips!(vlans, domain)
      large = vlans[:large]

      ip_reserved = large.ips.find_by!(address: "10.20.0.100")
      ip_reserved.update!(is_reserved: true, notes: "Reserved demo address — no host assignment.")

      ip_alias = large.ips.find_by!(address: "10.20.0.50")
      ip_alias.update!(
        hostname_alias: "svc-alias-demo",
        complete_hostname_alias: "svc-alias-demo.#{domain}",
        notes: "Hostname alias without host (search: svc-alias)."
      )

      ip_flags = large.ips.find_by!(address: "10.20.0.11")
      ip_flags.update!(include_in_etc_hosts: false, notes: "Excluded from generated /etc/hosts (legend demo).")

      ip_sort = large.ips.find_by!(address: "10.20.0.19")
      ip_sort.update!(notes: "Numeric order check: .19 comes before .187 (search: sanity-nineteen).")

      small = vlans[:small]
      small.ips.find_by!(address: "10.10.0.4").update!(use_vlan_descriptor: false, notes: "VLAN descriptor off for hostname rules demo.")
    end

    def seed_hosts!(vlans, tax)
      small = vlans[:small]
      large = vlans[:large]
      medium = vlans[:medium]

      web = Host.create!(
        name: "demo-web-01",
        description: "Web tier (cloud)",
        hosts_type: "Virtual Host",
        deployment_form: "cloud_vm",
        environment: tax[:env_prod],
        infrastructure: tax[:infra_aws],
        host_type: tax[:ht_web],
        memory_size: 4096,
        total_sockets: 1,
        total_vcpus: 4
      )
      web.ips << small.ips.find_by!(address: "10.10.0.2")

      api = Host.create!(
        name: "demo-api-01",
        description: "API tier (VMware)",
        hosts_type: "Virtual Host",
        deployment_form: "cloud_vm",
        environment: tax[:env_stg],
        infrastructure: tax[:infra_vmware],
        host_type: tax[:ht_web],
        memory_size: 8192,
        total_sockets: 2,
        total_vcpus: 8
      )
      api.ips << small.ips.find_by!(address: "10.10.0.3")

      db = Host.create!(
        name: "demo-db-01",
        description: "Database (rack mount, dual-homed)",
        hosts_type: "Physical Host",
        deployment_form: "rack_mount",
        server_rack: tax[:rack],
        rack_units: 2,
        rack_position_start: 10,
        environment: tax[:env_prod],
        infrastructure: tax[:infra_bare],
        host_type: tax[:ht_db],
        memory_size: 65_536,
        total_sockets: 2,
        total_vcpus: 32
      )
      db.ips << large.ips.find_by!(address: "10.20.0.10")
      db.ips << medium.ips.find_by!(address: "172.16.100.10")

      lb = Host.create!(
        name: "demo-lb-01",
        description: "Load balancer",
        hosts_type: "Virtual Host",
        deployment_form: "cloud_vm",
        environment: tax[:env_prod],
        infrastructure: tax[:infra_aws],
        host_type: tax[:ht_lb],
        memory_size: 2048,
        total_sockets: 1,
        total_vcpus: 2
      )
      lb.ips << large.ips.find_by!(address: "10.20.0.20")
    end

    # Access switch in the demo rack + one patched NIC on demo-db-01 (host ports / patch UI).
    def seed_network_demo!(tax)
      conn = ActiveRecord::Base.connection
      unless conn.table_exists?("network_switches") &&
          conn.table_exists?("switch_ports") &&
          conn.table_exists?("host_ports") &&
          conn.table_exists?("patch_connections")
        return
      end

      sw = NetworkSwitch.create!(
        name: "demo-sw-access-01",
        server_rack: tax[:rack],
        rack_units: 1,
        rack_position_start: 5,
        equipment_model: "Demo access",
        serial: "DEMO-SW-001",
        notes: "Demo switch for host ports and patch cables"
      )
      sw.create_default_ports!(8, name_template: "Gi1/0/")

      db_host = Host.find_by!(name: "demo-db-01")
      hp = HostPort.create!(
        host: db_host,
        name: "eno1",
        port_kind: "physical",
        mac_address: "AA:BB:CC:DD:EE:01",
        notes: "Demo NIC patched to access switch"
      )
      first_port = sw.switch_ports.order(:name).first
      PatchConnection.create!(
        host_port: hp,
        switch_port: first_port,
        label: "PP-demo / SW Gi1/0/1",
        cable_color: "yellow",
        installed_on: Date.current,
        notes: "Demo patch cable"
      )
    end

    def demo_network_suffix
      conn = ActiveRecord::Base.connection
      return "" unless conn.table_exists?("network_switches")

      ", #{NetworkSwitch.count} network switches"
    end

    def seed_externalips!(domain)
      Externalip.create!(
        address: "8.8.8.8",
        hostname: "google-public-dns-a.#{domain}",
        short_hostname: "g-dns-a",
        notes: "Demo external resolver",
        include_in_etc_hosts: true
      )
      Externalip.create!(
        address: "1.1.1.1",
        hostname: "cloudflare-dns.#{domain}",
        short_hostname: "cf-dns",
        notes: "Demo external resolver",
        include_in_etc_hosts: true
      )
      Externalip.create!(
        address: "9.9.9.9",
        hostname: "quad9-dns.#{domain}",
        short_hostname: "quad9",
        notes: "Demo external resolver",
        include_in_etc_hosts: true
      )
    end
  end
end
