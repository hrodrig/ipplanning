import { Controller } from "@hotwired/stimulus"

// Shows rack fields only when deployment_form is rack_mount.
export default class extends Controller {
  static targets = ["rackSection"]

  connect() {
    this.sync()
  }

  sync() {
    const sel = this.element.querySelector("#host_deployment_form")
    if (!sel || !this.hasRackSectionTarget) return
    const show = sel.value === "rack_mount"
    this.rackSectionTarget.classList.toggle("hidden", !show)
  }
}
