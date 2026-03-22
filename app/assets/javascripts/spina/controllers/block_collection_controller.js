import { Controller } from "@hotwired/stimulus";
import Sortable from "libraries/sortablejs";

export default class extends Controller {
  #abortController = null;
  #modalWasOpen = false;
  #modalObserver = null;

  get #searchQuery() {
    return this.hasSearchInputTarget ? this.searchInputTarget.value : "";
  }

  static get targets() {
    return [
      "list",
      "hiddenFields",
      "dropdown",
      "searchInput",
      "emptyMessage",
      "listItemTemplate",
      "groupHeaderTemplate",
      "dropdownOptionTemplate",
      "dropdownEmptyTemplate",
      "newBlockTemplate",
    ];
  }

  static get values() {
    return {
      blocks: Array, // [{id, name, templateName, templateTitle}]
      selectedIds: Array, // [id, id, ...]
      editUrl: String, // base edit_modal URL with __ID__ placeholder
      newUrl: String, // URL for new block modal
      blocksDataUrl: String, // JSON endpoint to refresh blocks list
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
    this.#observeModal();
  }

  disconnect() {
    if (this.sortable) this.sortable.destroy();
    if (this.#modalObserver) {
      this.#modalObserver.disconnect();
      this.#modalObserver = null;
    }
    this.#abortController?.abort();
    this.#abortController = null;
  }

  // --- Actions ---

  add(event) {
    event.preventDefault();
    const id = parseInt(event.currentTarget.dataset.blockId);
    if (this.selectedIdsValue.indexOf(id) !== -1) return;

    this.selectedIdsValue = this.selectedIdsValue.concat([id]);
    if (this.hasSearchInputTarget) {
      this.searchInputTarget.value = "";
    }
    this.render();
    this.closeDropdown();
  }

  remove(event) {
    event.preventDefault();
    const id = parseInt(event.currentTarget.dataset.blockId);
    this.selectedIdsValue = this.selectedIdsValue.filter((sid) => sid !== id);
    this.render();
  }

  onSearchInput() {
    this.renderDropdown();
    this.openDropdown();
  }

  onSearchFocus() {
    this.renderDropdown();
    this.openDropdown();
  }

  closeOnOutsideClick(event) {
    const clickedInsideSearch =
      this.hasSearchInputTarget &&
      this.searchInputTarget.contains(event.target);
    const clickedInsideDropdown = this.dropdownTarget.contains(event.target);

    if (!clickedInsideSearch && !clickedInsideDropdown) {
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
    let availableBlocks = this.blocksValue.filter((b) => {
      return this.selectedIdsValue.indexOf(b.id) === -1;
    });

    // Filter by search query
    const query = this.#searchQuery.toLowerCase().trim();
    if (query) {
      availableBlocks = availableBlocks.filter((b) => {
        return (
          b.name.toLowerCase().includes(query) ||
          (b.templateTitle && b.templateTitle.toLowerCase().includes(query)) ||
          (b.templateName && b.templateName.toLowerCase().includes(query))
        );
      });
    }

    this.dropdownTarget.innerHTML = "";

    if (availableBlocks.length === 0) {
      const empty = this.dropdownEmptyTemplateTarget.content.cloneNode(true);
      this.dropdownTarget.appendChild(empty);
    } else {
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
            option.querySelector("[data-role='title']").textContent =
              block.name;
            this.dropdownTarget.appendChild(option);
          });
        });
    }

    // "New block" link at the bottom of the dropdown
    if (
      this.hasNewBlockTemplateTarget &&
      this.hasNewUrlValue &&
      this.newUrlValue
    ) {
      const newBlock = this.newBlockTemplateTarget.content.cloneNode(true);
      const link = newBlock.querySelector("[data-role='new-block-link']");
      if (link) {
        link.href = this.newUrlValue;
      }
      this.dropdownTarget.appendChild(newBlock);
    }

    // Reposition if dropdown is currently visible
    if (this.dropdownTarget.style.display !== "none") {
      this.#positionDropdown();
    }
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

    const editLink = fragment.querySelector("[data-role='edit-link']");
    if (editLink && this.hasEditUrlValue && this.editUrlValue) {
      editLink.href = this.editUrlValue.replace("__ID__", block.id);
    }

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
    if (this.dropdownTarget.style.display === "block") {
      // Already open, just reposition
      this.#positionDropdown();
      return;
    }

    this.dropdownTarget.style.display = "block";
    this.#positionDropdown();

    this.#abortController = new AbortController();
    const { signal } = this.#abortController;

    document.addEventListener("click", (e) => this.closeOnOutsideClick(e), {
      capture: true,
      signal,
    });

    let scrollTimeout;
    const debouncedPosition = () => {
      clearTimeout(scrollTimeout);
      scrollTimeout = setTimeout(() => this.#positionDropdown(), 100);
    };
    window.addEventListener("scroll", debouncedPosition, {
      capture: true,
      signal,
    });
    window.addEventListener("resize", debouncedPosition, { signal });
  }

  closeDropdown() {
    this.dropdownTarget.style.display = "none";
    if (this.hasSearchInputTarget) {
      this.searchInputTarget.value = "";
    }
    this.#abortController?.abort();
    this.#abortController = null;
  }

  findBlock(id) {
    return this.blocksValue.find((b) => b.id === id);
  }

  // --- Private ---

  #positionDropdown() {
    const dropdown = this.dropdownTarget;
    const container = dropdown.parentElement;
    const containerRect = container.getBoundingClientRect();
    const dropdownHeight = dropdown.offsetHeight;
    const viewportHeight = window.innerHeight;

    const spaceBelow = viewportHeight - containerRect.bottom;
    const spaceAbove = containerRect.top;

    if (spaceBelow < dropdownHeight && spaceAbove > spaceBelow) {
      // Not enough space below and more space above, show above
      dropdown.style.bottom = "100%";
      dropdown.style.top = "auto";
      dropdown.style.marginBottom = "4px";
      dropdown.style.marginTop = "0";
    } else {
      // Default: show below
      dropdown.style.bottom = "auto";
      dropdown.style.top = "100%";
      dropdown.style.marginTop = "4px";
      dropdown.style.marginBottom = "0";
    }
  }

  #observeModal() {
    const modalFrame = document.querySelector("turbo-frame[id='modal']");
    if (!modalFrame || !this.hasBlocksDataUrlValue || !this.blocksDataUrlValue)
      return;

    this.#modalWasOpen = false;
    this.#modalObserver = new MutationObserver(() => {
      const hasModal = modalFrame.querySelector(".modal");
      if (hasModal) {
        this.#modalWasOpen = true;
      } else if (this.#modalWasOpen) {
        this.#modalWasOpen = false;
        this.refreshBlocks();
      }
    });
    this.#modalObserver.observe(modalFrame, { childList: true });
  }

  refreshBlocks() {
    fetch(this.blocksDataUrlValue, {
      headers: { Accept: "application/json" },
    })
      .then((response) => response.json())
      .then((blocks) => {
        this.blocksValue = blocks;
        this.render();
      });
  }
}
