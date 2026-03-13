import { Controller } from "@hotwired/stimulus";
import Sortable from "libraries/sortablejs";

export default class extends Controller {
  static get targets() {
    return [
      "list",
      "hiddenFields",
      "dropdown",
      "addButton",
      "emptyMessage",
      "listItemTemplate",
      "groupHeaderTemplate",
      "dropdownOptionTemplate",
      "dropdownEmptyTemplate",
    ];
  }

  static get values() {
    return {
      blocks: Array, // [{id, name, templateName, templateTitle}]
      selectedIds: Array, // [id, id, ...]
    };
  }

  connect() {
    // Sanitize: filter out any null/NaN/0 values from previously corrupted data
    this.selectedIdsValue = this.selectedIdsValue.filter((id) => {
      return id !== null && id !== undefined && !isNaN(id) && id > 0;
    });

    this.sortable = Sortable.create(this.listTarget, {
      handle: "[data-sortable-handle]",
      animation: 150,
      onEnd: this.reorderHiddenFields.bind(this),
    });
    this.render();
  }

  disconnect() {
    if (this.sortable) this.sortable.destroy();
  }

  // --- Actions ---

  add(event) {
    event.preventDefault();
    const id = parseInt(event.currentTarget.dataset.blockId);
    if (this.selectedIdsValue.indexOf(id) !== -1) return;

    this.selectedIdsValue = this.selectedIdsValue.concat([id]);
    this.render();
    this.closeDropdown();
  }

  remove(event) {
    event.preventDefault();
    const id = parseInt(event.currentTarget.dataset.blockId);
    this.selectedIdsValue = this.selectedIdsValue.filter((sid) => sid !== id);
    this.render();
  }

  toggleDropdown(event) {
    event.preventDefault();
    event.stopPropagation();
    const dropdown = this.dropdownTarget;
    if (dropdown.style.display === "none" || dropdown.style.display === "") {
      this.openDropdown();
    } else {
      this.closeDropdown();
    }
  }

  closeOnOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.closeDropdown();
    }
  }

  // --- Rendering ---

  render() {
    this.renderList();
    this.renderHiddenFields();
    this.renderDropdown();
    this.renderEmptyMessage();
  }

  renderList() {
    this.listTarget.innerHTML = "";
    this.selectedIdsValue.forEach((id) => {
      const block = this.findBlock(id);
      if (!block) return;
      this.listTarget.appendChild(this.buildListItem(block));
    });
  }

  renderHiddenFields() {
    const fieldName = this.element.dataset.fieldName;
    this.hiddenFieldsTarget.innerHTML = "";
    if (this.selectedIdsValue.length === 0) {
      // Empty sentinel: ensures the parameter is sent so Rails clears the array
      const input = document.createElement("input");
      input.type = "hidden";
      input.name = fieldName;
      input.value = "";
      this.hiddenFieldsTarget.appendChild(input);
    } else {
      this.selectedIdsValue.forEach((id) => {
        const input = document.createElement("input");
        input.type = "hidden";
        input.name = fieldName;
        input.value = id;
        this.hiddenFieldsTarget.appendChild(input);
      });
    }
  }

  renderDropdown() {
    const availableBlocks = this.blocksValue.filter((b) => {
      return this.selectedIdsValue.indexOf(b.id) === -1;
    });

    this.dropdownTarget.innerHTML = "";

    if (availableBlocks.length === 0) {
      const empty = this.dropdownEmptyTemplateTarget.content.cloneNode(true);
      this.dropdownTarget.appendChild(empty);
      return;
    }

    // Group by templateTitle
    const groups = {};
    availableBlocks.forEach((b) => {
      const key = b.templateTitle || b.templateName || "Other";
      if (!groups[key]) groups[key] = [];
      groups[key].push(b);
    });

    Object.keys(groups)
      .sort()
      .forEach((groupName) => {
        const header = this.groupHeaderTemplateTarget.content.cloneNode(true);
        header.querySelector("[data-role='group-name']").textContent =
          groupName;
        this.dropdownTarget.appendChild(header);

        groups[groupName].forEach((block) => {
          const option =
            this.dropdownOptionTemplateTarget.content.cloneNode(true);
          const button = option.querySelector("button");
          button.dataset.blockId = block.id;
          option.querySelector("[data-role='title']").textContent = block.name;
          this.dropdownTarget.appendChild(option);
        });
      });
  }

  renderEmptyMessage() {
    if (this.hasEmptyMessageTarget) {
      this.emptyMessageTarget.style.display =
        this.selectedIdsValue.length === 0 ? "" : "none";
    }
  }

  // --- Helpers ---

  buildListItem(block) {
    const fragment = this.listItemTemplateTarget.content.cloneNode(true);
    const root = fragment.querySelector("[data-block-id]");
    root.dataset.blockId = block.id;
    fragment.querySelector("[data-role='title']").textContent = block.name;
    fragment.querySelector("[data-role='template-label']").textContent =
      "(" + (block.templateTitle || block.templateName) + ")";
    fragment.querySelector(
      "[data-action='block-collection#remove']",
    ).dataset.blockId = block.id;
    return fragment;
  }

  reorderHiddenFields() {
    // :scope > selects only direct children, not nested buttons that also have data-block-id
    const items = this.listTarget.querySelectorAll(":scope > [data-block-id]");
    const ids = [];
    items.forEach((el) => {
      ids.push(parseInt(el.dataset.blockId));
    });
    this.selectedIdsValue = ids;
    this.renderHiddenFields();
  }

  openDropdown() {
    this.dropdownTarget.style.display = "block";
    this._outsideClickHandler = this.closeOnOutsideClick.bind(this);
    document.addEventListener("click", this._outsideClickHandler, true);
  }

  closeDropdown() {
    this.dropdownTarget.style.display = "none";
    if (this._outsideClickHandler) {
      document.removeEventListener("click", this._outsideClickHandler, true);
      this._outsideClickHandler = null;
    }
  }

  findBlock(id) {
    return this.blocksValue.find((b) => b.id === id);
  }
}
