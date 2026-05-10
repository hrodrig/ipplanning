import { Controller } from "@hotwired/stimulus"

// Client-side filter for IP list rows (addresses, VLAN fields, hostnames, notes).
export default class extends Controller {
  static targets = ["input", "hint", "empty"]
  static values = {
    matchesTemplate: { type: String, default: "" }
  }

  connect() {
    this.filter()
  }

  clear(event) {
    event.preventDefault()
    this.inputTarget.value = ""
    this.filter()
  }

  filter() {
    const q = this.inputTarget.value.trim().toLowerCase()
    const rows = this.element.querySelectorAll("tr[data-ip-search]")

    rows.forEach((row) => {
      const hay = row.getAttribute("data-ip-search") || ""
      const show = !q || hay.includes(q)
      row.classList.toggle("hidden", !show)
    })

    this.element.querySelectorAll("details.ip-index-chunk").forEach((d) => {
      const bodyRows = d.querySelectorAll("tbody tr[data-ip-search]")
      const any = [...bodyRows].some((r) => !r.classList.contains("hidden"))
      if (!q) {
        d.classList.remove("hidden")
        d.open = d.getAttribute("data-default-open") === "true"
        return
      }
      d.classList.toggle("hidden", !any)
      if (any) d.open = true
    })

    this.element.querySelectorAll("[data-ip-table-wrap]").forEach((wrap) => {
      const bodyRows = wrap.querySelectorAll("tbody tr[data-ip-search]")
      const any = [...bodyRows].some((r) => !r.classList.contains("hidden"))
      if (!q) {
        wrap.classList.remove("hidden")
        return
      }
      wrap.classList.toggle("hidden", !any)
    })

    this.element.querySelectorAll("[data-ip-vlan-section]").forEach((sec) => {
      const secRows = sec.querySelectorAll("tr[data-ip-search]")
      if (!q) {
        sec.classList.remove("hidden")
        return
      }
      const any = [...secRows].some((r) => !r.classList.contains("hidden"))
      sec.classList.toggle("hidden", !any)
    })

    this.element.querySelectorAll("[data-ip-external-block]").forEach((block) => {
      const extRows = block.querySelectorAll("tr[data-ip-search]")
      if (!q) {
        block.classList.remove("hidden")
        return
      }
      const any = [...extRows].some((r) => !r.classList.contains("hidden"))
      block.classList.toggle("hidden", !any)
    })

    const nVisible = [...rows].filter((r) => !r.classList.contains("hidden")).length

    if (this.hasEmptyTarget) {
      this.emptyTarget.classList.toggle("hidden", !(q.length > 0 && nVisible === 0))
    }

    if (this.hasHintTarget) {
      if (q.length > 0) {
        const tpl = this.matchesTemplateValue || ""
        this.hintTarget.textContent = tpl.includes("%{count}")
          ? tpl.replace(/%\{count\}/g, String(nVisible))
          : String(nVisible)
      } else {
        this.hintTarget.textContent = ""
      }
    }
  }
}
