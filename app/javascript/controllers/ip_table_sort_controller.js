import { Controller } from "@hotwired/stimulus"

const TEXT_COLUMNS = {
  complete: "sortComplete",
  short: "sortShort",
  notes: "sortNotes",
  extras: "sortExtras"
}

// Click column headers to sort table rows (numeric IPv4 + text columns).
export default class extends Controller {
  connect() {
    this.column = null
    this.direction = 1
  }

  sort(event) {
    const column = event.params.column
    if (this.column === column) {
      this.direction = -this.direction
    } else {
      this.column = column
      this.direction = 1
    }

    const tbody = this.element.querySelector("tbody")
    if (!tbody) return

    const rows = Array.from(tbody.querySelectorAll("tr[data-sort-ip]"))
    const mult = this.direction

    rows.sort((a, b) => {
      let cmp = 0
      if (column === "ip") {
        cmp = (Number(a.dataset.sortIp) || 0) - (Number(b.dataset.sortIp) || 0)
      } else {
        const dk = TEXT_COLUMNS[column]
        const as = dk ? (a.dataset[dk] ?? "") : ""
        const bs = dk ? (b.dataset[dk] ?? "") : ""
        cmp = as.localeCompare(bs, undefined, { sensitivity: "base", numeric: true })
      }
      if (cmp === 0) {
        cmp = (Number(a.dataset.sortIp) || 0) - (Number(b.dataset.sortIp) || 0)
      }
      return cmp * mult
    })

    rows.forEach((row) => tbody.appendChild(row))

    this.element.querySelectorAll("[data-sort-marker]").forEach((el) => {
      el.textContent = ""
    })
    const mark = event.currentTarget.querySelector("[data-sort-marker]")
    if (mark) mark.textContent = this.direction > 0 ? "↑" : "↓"

    this.element.querySelectorAll("tbody tr td.js-row-index").forEach((cell, i) => {
      cell.textContent = String(i + 1)
    })
  }
}
