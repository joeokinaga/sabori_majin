// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
Turbo.session.drive = false
// import * as bootstrap from "bootstrap"
// document.addEventListener("turbo:load", () => {
//   document.querySelectorAll('.dropdown-toggle').forEach((el) => {
//     if (!el.dataset.bsDropdown) {
//       new bootstrap.Dropdown(el)
//     }
//   })
// })