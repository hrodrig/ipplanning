import { Controller } from "@hotwired/stimulus"

const STORAGE_KEY = "ipplanning-theme"

export default class extends Controller {
  static targets = ["moon", "sun", "control"]
  static values = {
    darkLabel: String,
    lightLabel: String
  }

  connect() {
    this.refresh()
  }

  toggle(event) {
    event.preventDefault()
    const root = document.documentElement
    root.classList.toggle("dark")
    const mode = root.classList.contains("dark") ? "dark" : "light"
    try {
      localStorage.setItem(STORAGE_KEY, mode)
    } catch (_) {
      /* private mode */
    }
    this.refresh()
  }

  refresh() {
    const dark = document.documentElement.classList.contains("dark")
    this.moonTargets.forEach((el) => el.classList.toggle("hidden", dark))
    this.sunTargets.forEach((el) => el.classList.toggle("hidden", !dark))
    const nextAction = dark ? this.lightLabelValue : this.darkLabelValue
    this.controlTargets.forEach((btn) => {
      btn.setAttribute("aria-label", nextAction)
      btn.setAttribute("title", nextAction)
    })
  }
}
