# IPPLANNING Specifications

**Document version:** aligned with app release **0.9.0** (see [`VERSION`](VERSION)).

## 1. Overview
IPPLANNING is a web-based IP Address Management (IPAM) application designed for network administrators to manage VLANs, IP allocations, and Host assignments. It also supports **physical inventory** cues such as **locations**, **server racks**, and **network switches** (with per-switch ports) for operators who want rack context without modeling switches as hosts. A key unique feature is its ability to generate synchronized `/etc/hosts` files, which is particularly valuable in environments where high-frequency name resolution is required and DNS latency or implementation is a concern (e.g., SAP, Oracle clusters).

## 2. Core Domain Model

### 2.1 Entity Relationship Diagram (ERD)

```mermaid
erDiagram
    Vlan ||--o{ Ip : "contains"
    Ip }o--o{ Host : "assigned to"
    Host }|--|| Environment : "belongs to"
    Host }|--|| Infrastructure : "belongs to"
    Host }|--|| HostType : "classified as"
    Location ||--o{ ServerRack : "contains"
    ServerRack }o--|| Location : "at"
    ServerRack ||--o{ Host : "rack_mount"
    ServerRack ||--o{ NetworkSwitch : "has"
    NetworkSwitch ||--o{ SwitchPort : "has"
    Externalip {
        string address
        string hostname
        string short_hostname
        boolean include_in_etc_hosts
    }
    Setting {
        string name
        string value
        text description
    }
    Admin {
        string email
        string encrypted_password
    }
    User {
        string email
        string encrypted_password
    }
```

### 2.2 Model Definitions

| Model | Description | Key Attributes |
| :--- | :--- | :--- |
| **Vlan** | Represents a logical network segment. | `number`, `name`, `network`, `netmask`, `gateway`, `descriptor` |
| **Ip** | Represents a specific IP address within a VLAN. | `address`, `include_in_etc_hosts`, `hostname_alias`, `is_reserved`, `is_default_gateway` (§3.11); see §3.5–3.7 for list UX, search, and sort helpers (`searchable_text`, `ipv4_sort_integer`, `sort_key_extras_ips`) |
| **Host** | Represents a physical or virtual machine. | `name`, `description`, `memory_size`, `total_vcpus` |
| **Externalip** | Standalone entries for external IPs to be included in `/etc/hosts`. | `address`, `hostname`, `short_hostname`; shares IPv4 ordering helpers with `Ip` via `Ipv4AddressSortable` (§3.7) |
| **Environment** | Classification for host lifecycles. | `name` (e.g., Production, Staging, QA, Development) |
| **Infrastructure**| Hosting platform classification. | `name` (e.g., VMWare, AWS, Bare Metal, Azure) |
| **HostType** | Functional classification of the host. | `name` (e.g., DB Server, App Server, Load Balancer) |
| **Setting** | Global application configuration. | `name`, `value` (e.g., WebsiteName, DomainName) |
| **Location** | Physical site (building, room, cage). | `name`, `description` |
| **ServerRack** | Cabinet within a location. | `name`, `u_height`, `notes`; `has_many` hosts (rack-mount) and network switches |
| **NetworkSwitch** | Switch hardware tracked **outside** the Host model. | `name` (unique), `serial`, `equipment_model` (not the reserved AR name `model`), rack fields, firmware, management hint, photos (Active Storage); optional `belongs_to :server_rack` |
| **SwitchPort** | Labelled port on a switch. | `name` (unique per `network_switch_id`); batch-created on switch create |

---

## 3. Functional Specifications

### 3.1 VLAN & Network Management
- **VLAN Definition:** Admins can create VLANs by specifying a network address and CIDR netmask.
- **Network Generation:** The `generate_network` action uses the `ipaddress` library to automatically populate a VLAN with all valid host IP addresses in its range (`find_or_create_by!` per address so re-runs do not violate uniqueness).
- **Single IP create:** Admins can add **one** IP to an existing VLAN via member routes `GET /vlans/:id/new_ip` and `POST /vlans/:id/create_ip` (`new_ip` / `create_ip` on `VlansController`). The new address must fall inside the VLAN’s network/netmask (validated on `Ip` with the `ipaddress` gem; i18n errors under `activerecord.errors.models.ip.attributes.address`).
- **Reserved IPs:** IPs can be marked as `is_reserved`, preventing them from being associated with a Host.

### 3.2 Host & IP Assignment
- **Many-to-Many Relationship:** A Host can have multiple IPs (across different VLANs), and an IP can be associated with a Host.
- **Hostname Logic:** The application dynamically calculates hostnames:
  - **Short Hostname:** `host.name` + optional `vlan.descriptor`.
  - **Long Hostname (FQDN):** `short_hostname` + global `DomainName` setting.
  - **Alias Support:** IPs can have custom `hostname_alias` which overrides default calculations.

### 3.3 /etc/hosts Generation
- **Automated Export:** Generates a standard `/etc/hosts` formatted string.
- **Selection Logic:** Only IPs and VLANs marked with `include_in_etc_hosts` are included.
- **Header Metadata:** Includes generation timestamps and audit information.
- **Downloadable:** Available via a dedicated endpoint (`/etc/hosts/download`).

### 3.4 Security & Access Control
- **Role-Based Auth:**
  - **Admins:** Full access to manage VLANs, IPs, Hosts, and Settings.
  - **Users:** (Reserved for future read-only or limited access).
- **HTTP Basic Auth:** Optional secondary security layer configured via global settings (`BasicAuthRequired`).

### 3.5 IP list presentation (admin IPs index & home)
Large VLANs (many rows) are easier to scan using **chunked, collapsible blocks** and constrained scroll:

- **Chunking rule:** If a VLAN has **more than 64** IP rows, addresses are split into contiguous slices of up to **64** records each (ordered numerically by IPv4; see §3.7).
- **Collapsible UI:** Each slice is rendered as a `<details class="ip-index-chunk">` block with a summary showing address range and counts (total addresses vs. addresses with a host).
- **Default open state:** The **first** chunk is open by default; others start collapsed. Attribute `data-default-open` preserves this for resetting UI after clearing filters (§3.6).
- **Scroll:** The table body inside an open chunk uses a **max-height** with vertical scroll so the page does not grow unbounded.
- **Sticky header:** Shared partial `_ip_table_head` renders a **sticky** `<thead>` while scrolling within a chunk.
- **Single-table VLANs:** VLANs with ≤64 IPs use one table wrapped with `data-ip-table-wrap` (scroll when row count is high but still a single block).
- **Styling:** Chevron rotation on open/closed chunks is handled in Tailwind/application CSS (`.ip-index-chunk`).

### 3.6 IP list search & filter (client-side)
Authenticated **IPs** index and **home** (`welcome#index`) expose a **search** field that filters rows **in the browser** (no server round-trip):

- **Stimulus controller:** `ip-index-filter` (`app/javascript/controllers/ip_index_filter_controller.js`).
- **Row metadata:** Each IP row exposes `data-ip-search` with a normalized, HTML-escaped blob from `Ip#searchable_text` (address, aliases, hostnames, notes, VLAN fields, linked host names, etc.). External IP rows on the home page use a smaller derived blob (address, hostnames, notes).
- **Behavior:**
  - Rows that do not match the query are hidden (`hidden` / `classList`).
  - For chunked VLANs, `<details.ip-index-chunk>` blocks with **no** visible rows are hidden; blocks with matches are shown and **opened** while filtering.
  - VLAN sections and the external-IP block use `data-ip-vlan-section` / `data-ip-external-block` to hide entire sections when nothing matches.
  - **Clear** resets the query, visibility, and chunk `open` state according to `data-default-open`.
- **UX copy:** Filter label, placeholder, clear action, match count template, and empty-state message are localized (`ips_filter_*` keys).

### 3.7 IP ordering & table column sorting
**Correct IPv4 order (not lexicographic):** Sorting by the string `address` places `…201.19` after `…201.189`. The application therefore uses **numeric IPv4 ordering**:

- **Concern:** `Ipv4AddressSortable` (`app/models/concerns/ipv4_address_sortable.rb`), included in `Ip` and `Externalip`.
- **Database (MySQL):** Scope `order_by_ipv4_address` uses `ORDER BY INET_ATON(address) ASC` on the model table. Used for VLAN IP lists, host IP summaries, `/etc/hosts` generation order, external IP listings, etc.
- **Fallback:** Non-MySQL adapters fall back to `order(:address)` until a portable expression is added.
- **32-bit sort key:** `ipv4_sort_integer` packs a valid dotted IPv4 into an integer for client-side tie-breaking and attributes.

**Interactive column sort (Stimulus):**

- **Controller:** `ip-table-sort` (`app/javascript/controllers/ip_table_sort_controller.js`) on each sortable `<table>`.
- **Headers:** Address, complete hostname, short hostname, extras, and notes columns use buttons that cycle **ascending / descending** on repeated clicks; a small **↑ / ↓** marker shows the active column.
- **Row `data-*` keys:** `data-sort-ip`, `data-sort-complete`, `data-sort-short`, `data-sort-extras`, `data-sort-notes` (populated from `Ip` fields and `sort_key_extras_ips` for the extras column).
- **External IPs (admin index & home):** Same pattern for IP, hostname, short hostname, and notes; the admin list’s `#` column uses `js-row-index` so row numbers stay **1…n** after reordering.

### 3.8 Demo sandbox dataset & reset
- **Purpose:** A throwaway dataset for public demos or scheduled sandboxes so users can explore CRUD, large IP lists, search, and sorting without polluting long-lived data.
- **Implementation:** `Demo::Populator` in `lib/demo/populator.rb` deletes core rows (`hosts_ips`, IPs, hosts, VLANs, taxonomy, external IPs, locations/racks, users, admins, settings, Active Storage) and recreates representative records (including a `/24` VLAN for chunk UX).
- **Rake tasks:** `rails demo:reset` (purge + populate), `rails demo:purge`, `rails demo:populate` (see `lib/tasks/demo.rake`).
- **Guardrail:** Outside Rails `local?` environments, tasks require **`DEMO_RESET_ALLOWED=1`**. Optional env: `DEMO_ADMIN_EMAIL`, `DEMO_ADMIN_PASSWORD`.
- **Operations:** Cron-friendly; README documents a **2-hour** example schedule.

### 3.9 Server rack front (U) diagram
- **Purpose:** Visualize rack capacity and placement of **rack-mount** hosts and **network switches** (`NetworkSwitch`) in the rack without external DCIM tooling.
- **Layout:** HTML/CSS (Tailwind): one row per rack unit, **highest U at the top** down to **U1 at the bottom** (EIA-310: U1 is the bottom of the rack).
- **Placement rule:** `rack_position_start` is the **lowest U** occupied; `rack_units` consecutive Us count upward (hosts and switches use the same rule, e.g. start 21, units 2 → U21–U22).
- **Colors:** Neutral = free; **green** = host; **indigo** = network switch; **amber / strong border** = **focused** item (`highlight_host_id` or `highlight_network_switch_id` on the rack show URL, validated against that rack).
- **Surfaces:** `server_racks#show` embeds the diagram; `hosts#show` and `network_switches#show` embed it when a rack is linked, passing the current record as focus. Host and switch list entries on the rack can link a **U range** label back to the rack with focus.
- **Helpers / partial:** `RackUDiagramHelper` (`rack_u_diagram_rows`, `host_rack_u_range_label`, `network_switch_rack_u_range_label`) and `server_racks/_u_diagram.html.erb`. Hosts or switches missing valid U data trigger warning banners; they still appear in the textual lists.

### 3.10 Network switches & switch ports (admin)
- **Purpose:** Inventory **L2/L3 switches** without conflating them with **Host** records (no IP assignment workflow on the switch model in this release).
- **Admin UI:** Full CRUD under **Platform settings → Network switches**; nested **switch ports** (new/create/edit/update/destroy). Rack show page lists linked switches with U-range links (`highlight_network_switch_id`).
- **Batch ports on create:** The new-switch form accepts **`port_count`** (not persisted on `NetworkSwitch`) and an optional **`default_port_name_template`**. If the template is blank, ports are named `1`…`N`. If it ends with digits (e.g. `Gi1/0/1`), that suffix is the start index and increments per port, preserving zero-padding width (e.g. `…09`, `…10`). If there is no trailing digit run (e.g. `Gi1/0/`), the suffix `1`, `2`, … is appended. Implementation: `NetworkSwitch.build_default_port_names` + `insert_all!` on `SwitchPort`.
- **Display order:** `SwitchPort.sort_ports_for_display` orders purely numeric names numerically; names with a trailing digit run (e.g. `Gi1/0/10`) sort by that numeric suffix; other strings sort alphabetically in a final group.
- **Data integrity:** Deleting a rack with assigned switches is blocked (`restrict_with_error` on `ServerRack#network_switches`), analogous to hosts.

### 3.11 VLAN IP maintenance & default gateway (0.9.0)
- **VLAN navigation:** On `vlans#show`, other VLANs are linked in a **single horizontal, wrapping** control (`_menu_vlans`) instead of legacy stacked tabs markup.
- **Add IP from VLAN context:** From VLAN show, IPs index, or VLANs index, admins can open **Add IP to VLAN**; after create, the app redirects to the IPs index (bulk list), unless future UX changes that flow.
- **Delete IP from VLAN table:** VLAN show lists IPs with a compact **delete** control (`DELETE /ips/:id` with query `from_vlan=<vlan_id>`). When `from_vlan` matches the IP’s VLAN, the controller redirects back to **`vlan_path(vlan)`** and **does not** use a browser confirm dialog; a visible **responsibility notice** (`vlan_ip_delete_responsibility_notice`) explains that deletion is immediate. Other surfaces (e.g. IPs index row partial) keep **`turbo_confirm`** on destroy.
- **Default gateway flag:** `Ip#is_default_gateway` (boolean, default false). At most one IP per VLAN should be marked: when an IP is saved with `is_default_gateway: true`, other IPs on that VLAN are cleared and **`Vlan#gateway`** is updated to that IP’s `address`. **Row highlight** (gateway styling) uses `Ip#default_gateway_row?(vlan)` — true if the flag is set **or** the legacy condition `address == vlan.gateway` matches (covers older data and manual VLAN edits). The IP edit form and VLAN “add IP” form expose the checkbox; `searchable_text` includes a `defaultgateway` token when the flag is set for client-side filtering.

---

## 4. Technical Workflows

### 4.1 IP Generation Flow
```mermaid
sequenceDiagram
    participant Admin
    participant VlansController
    participant IPAddressLib
    participant Database

    Admin->>VlansController: Click "Generate Network"
    VlansController->>IPAddressLib: Parse network/netmask (e.g., 10.0.0.0/24)
    IPAddressLib-->>VlansController: Return host addresses list
    loop For each IP Address
        VlansController->>Database: Create Ip record (belongs to VLAN)
    end
    VlansController-->>Admin: Redirect to VLAN view with populated IPs
```

### 4.2 /etc/hosts Export Flow
```mermaid
sequenceDiagram
    participant Server
    participant IpModel
    participant Database

    Server->>IpModel: Call generate_etc_hosts
    IpModel->>Database: Fetch VLANs (ordered by number)
    IpModel->>Database: Fetch IPs (where include_in_etc_hosts = true), ordered by IPv4 (`INET_ATON(address)` on MySQL)
    IpModel->>Database: Fetch External IPs
    IpModel-->>Server: Return formatted String
```

---

## 5. UI/UX Standards
- **Framework:** Tailwind CSS v4.
- **Responsiveness:** Mobile-first design with a responsive sidebar/navbar.
- **Interactivity:** Hotwire (Turbo & Stimulus) for seamless page transitions without full reloads.
- **Feedback:** Standardized Tailwind-styled alerts for notices and errors.
- **IP-heavy views:** Chunked VLAN tables (§3.5), client-side filter (`ip-index-filter`, §3.6), and per-table column sort (`ip-table-sort`, §3.7) on the admin IPs index, home VLAN tables, and external IP tables where implemented.
- **Operator guide:** Collapsible IP blocks and the search box are also summarized under `section_intro.ips` tips in locale files (`en.yml` / `es.yml`).
- **Rack views:** Front-of-rack **U** diagram per §3.9.
- **Network switch forms:** `autocomplete="off"` on the switch form and key text inputs to reduce browser autofill mixing `name` vs `equipment_model`; model field grouped under the switch name with a short example placeholder.

---

## 6. Glossary
- **IPAM:** IP Address Management.
- **VLAN Descriptor:** A short tag (e.g., `mgm`, `srv`) added to hostnames to distinguish interfaces.
- **Safe Navigation:** Ruby pattern (`&.`) used to prevent crashes when accessing settings that might not be initialized.
