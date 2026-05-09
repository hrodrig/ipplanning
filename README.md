# IPPLANNING: IP Address Management System (IPAM)

<p align="center">
  <img src="https://images.unsplash.com/photo-1558494949-ef010cbdcc31?auto=format&fit=crop&w=1200&q=80" alt="IPPLANNING Hero Image" width="100%" style="border-radius: 10px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);">
</p>

![Rails Version](https://img.shields.io/badge/Rails-8.0-red)
![Ruby Version](https://img.shields.io/badge/Ruby-3.3-red)
![Frontend](https://img.shields.io/badge/Frontend-Hotwire%20%2B%20Tailwind-blue)

IPPLANNING is a powerful, lightweight, and modern IP Address Management (IPAM) system built with Ruby on Rails 8. It is designed to help system administrators and DevOps engineers manage network segments, VLANs, and host assignments with ease, focusing on high-performance environments like SAP and Oracle.

---

## ⚡ Quickstart (The 60-Second Setup)

1. **Clone & Install:**
   ```bash
   git clone https://github.com/your-username/ipplanning.git && cd ipplanning
   bundle install
   ```

2. **Configure Database:**
   Update `config/database.yml` with your MySQL credentials. If you want to use the defaults, run this in your MySQL console:
   ```sql
   CREATE USER 'user'@'localhost' IDENTIFIED BY 'password';
   CREATE DATABASE ipplanning_development;
   CREATE DATABASE ipplanning_test;
   GRANT ALL PRIVILEGES ON ipplanning_development.* TO 'user'@'localhost';
   GRANT ALL PRIVILEGES ON ipplanning_test.* TO 'user'@'localhost';
   FLUSH PRIVILEGES;
   ```

3. **Initialize & Run:**
   ```bash
   bin/rails db:prepare app:setup
   bin/dev
   ```
*Login at `http://localhost:3000` after creating your admin in the console (see [User Management](#-user-management)).*

---

## 📋 Table of Contents

1. [Key Features](#-key-features)
2. [Why IPPLANNING?](#-why-ipplanning)
3. [Tech Stack](#-tech-stack)
4. [Installation & Setup](#-installation--setup)
5. [User Management](#-user-management)
6. [Basic Configuration](#-basic-configuration)
7. [Contributing](#-contributing)
8. [License](#-license)

---

## 🚀 Key Features

- **VLAN Management:** Easily define and organize network segments.
- **IP Allocation:** Keep track of every IP address within your VLANs.
- **Infrastructure Mapping:** Track resource allocation (vCPUs, RAM, Sockets) across different environments (Production, Development, QA).
- **Automated `/etc/hosts` Generation:** Generate synchronized host files for Unix-like servers, essential for environments where DNS resolution is a bottleneck.
- **Modern UI:** Clean and responsive interface built with Tailwind CSS.
- **External IP Tracking:** Manage public or external IPs associated with your internal hosts.

[↑ Back to Top](#-table-of-contents)

---

## 💡 Why IPPLANNING?

In large-scale distributed environments (especially SAP or Oracle), name resolution performance is critical. Many organizations prefer using `/etc/hosts` files over DNS to minimize latency and dependency on external services.

IPPLANNING simplifies this by providing a single source of truth for your network topology, allowing you to export and synchronize host files across your entire infrastructure effortlessly.

[↑ Back to Top](#-table-of-contents)

---

## 🛠 Tech Stack

- **Backend:** [Ruby on Rails 8.0](https://rubyonrails.org/)
- **Runtime:** [Ruby 3.3+](https://www.ruby-lang.org/)
- **Database:** MySQL / MariaDB
- **Frontend:** [Tailwind CSS v4](https://tailwindcss.com/), [Hotwire](https://hotwired.dev/) (Turbo & Stimulus)
- **Assets:** [Propshaft](https://github.com/rails/propshaft) & [Importmaps](https://github.com/rails/importmap-rails) (No Node.js required)
- **Auth:** [Devise](https://github.com/heartcombo/devise)

[↑ Back to Top](#-table-of-contents)

---

## 📥 Installation & Setup

### Prerequisites

- Ruby 3.3.0 or higher (Managed via RVM recommended)
- MySQL 5.7+ or MariaDB
- Bundler 2.5+

### Step-by-Step Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/ipplanning.git
   cd ipplanning
   ```

2. **Configure RVM (Optional but recommended):**
   ```bash
   rvm use ruby-3.3.0@ipplanning --create
   ```

3. **Install dependencies:**
   ```bash
   bundle install
   ```

4. **Setup the database:**
   *(Make sure to update `config/database.yml` with your local credentials)*
   ```bash
   bin/rails db:prepare
   ```

5. **Initialize application settings:**
   ```bash
   bin/rails app:setup
   ```

6. **Start the development server:**
   ```bash
   bin/dev
   ```

[↑ Back to Top](#-table-of-contents)

---

## 👤 User Management

For security reasons, user registration is disabled via the web interface. To create your first administrator:

1. **Open the Rails Console:**
   ```bash
   bin/rails c
   ```

2. **Create the Admin User:**
   ```ruby
   Admin.create!(email: 'admin@example.com', password: 'your_secure_password')
   ```

[↑ Back to Top](#-table-of-contents)

---

## ⚙️ Basic Configuration

Once logged in, navigate to the **Settings** section to configure:
- **Brand & Website Name:** Customize the app's appearance.
- **Domain Name:** Define your default internal domain.
- **Auth Requirements:** Enable or disable additional HTTP Basic Auth for specific endpoints.

[↑ Back to Top](#-table-of-contents)

---

## 🤝 Contributing

We welcome contributions! Please feel free to submit a Pull Request.
1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

[↑ Back to Top](#-table-of-contents)

---

## 📜 License

Distributed under the MIT License. See `LICENSE` for more information.

---
*Developed by Hermes Rodríguez - Updated for Rails 8 & Modern Standards.*
