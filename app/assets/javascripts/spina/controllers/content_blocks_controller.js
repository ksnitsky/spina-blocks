import { Controller } from "@hotwired/stimulus"
import Sortable from "libraries/sortablejs"
import { positionDropdown } from "spina/utils/dropdown_position"

// Manages a list of typed content blocks with add, remove, reorder, and collapse.
//
// Each block type has a pre-rendered <template> element. When the user adds a
// block, the template is cloned and the placeholder child_index is replaced
// with a unique timestamp so Rails form params are unique.
export default class extends Controller {
  static targets = [
    "list",
    "block",
    "blockContent",
    "emptyMessage",
    "typeMenu",
    "blockTemplate"
  ]

  #abortController = null

  connect() {
    this.sortable = Sortable.create(this.listTarget, {
      handle: "[data-sortable-handle]",
      animation: 150
    })
    this._updateEmptyMessage()
  }

  disconnect() {
    if (this.sortable) this.sortable.destroy()
    this.#abortController?.abort()
    this.#abortController = null
  }

  // --- Actions ---

  addBlock(event) {
    event.preventDefault()
    const blockType = event.currentTarget.dataset.blockType
    const template = this.blockTemplateTargets.find(
      t => t.dataset.blockType === blockType
    )
    if (!template) return

    const childIndex = template.dataset.childIndex
    const uniqueId = new Date().getTime().toString()
    const regex = new RegExp(childIndex, "g")

    // Clone template content and replace placeholder child_index
    const html = template.innerHTML.replace(regex, uniqueId)
    this.listTarget.insertAdjacentHTML("beforeend", html)

    this._closeTypeMenu()
    this._updateEmptyMessage()
  }

  removeBlock(event) {
    event.preventDefault()
    if (!confirm("Are you sure you want to remove this block?")) return

    const block = event.currentTarget.closest(`[data-${this.identifier}-target='block']`)
    if (block) {
      block.remove()
      this._updateEmptyMessage()
    }
  }

  toggleTypeMenu(event) {
    event.preventDefault()
    const menu = this.typeMenuTarget
    const isOpen = menu.style.display !== "none"

    if (isOpen) {
      this._closeTypeMenu()
    } else {
      menu.style.display = "block"
      positionDropdown(menu)
      this.#abortController = new AbortController()
      const { signal } = this.#abortController

      // Close on outside click (delayed to avoid catching the current click)
      setTimeout(() => {
        document.addEventListener("click", (e) => {
          if (!menu.contains(e.target) && !event.currentTarget.contains(e.target)) {
            this._closeTypeMenu()
          }
        }, { capture: true, once: true, signal })
      }, 0)
    }
  }

  toggleCollapse(event) {
    event.preventDefault()
    const block = event.currentTarget.closest(`[data-${this.identifier}-target='block']`)
    if (!block) return

    const content = block.querySelector(`[data-${this.identifier}-target='blockContent']`)
    if (content) {
      content.style.display = content.style.display === "none" ? "" : "none"
    }
  }

  // --- Private ---

  _closeTypeMenu() {
    this.typeMenuTarget.style.display = "none"
    this.#abortController?.abort()
    this.#abortController = null
  }

  _updateEmptyMessage() {
    if (this.hasEmptyMessageTarget) {
      const hasBlocks = this.listTarget.children.length > 0
      this.emptyMessageTarget.style.display = hasBlocks ? "none" : ""
    }
  }
}
