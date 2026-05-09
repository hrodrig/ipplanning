import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "menu", "dropdown" ]

  toggleMenu() {
    this.menuTarget.classList.toggle("hidden")
  }

  toggleDropdown(event) {
    event.preventDefault()
    this.dropdownTarget.classList.toggle("hidden")
  }
}
