import { Controller } from "@hotwired/stimulus";

// Toggles a BlockReference part between "reference" (select a shared block)
// and "inline" (fill the block template's fields in on the page itself).
//
// Styled and driven like Spina's own tabs: active/inactive class lists come
// from data attributes on the controller element. We don't reuse the `tabs`
// controller because it always activates the first button on connect, which
// would misreport the persisted mode.
export default class extends Controller {
  static get targets() {
    return ["button", "referencePane", "inlinePane", "modeField"];
  }

  connect() {
    this.#apply(this.hasModeFieldTarget ? this.modeFieldTarget.value : "reference");
  }

  switch(event) {
    this.#apply(event.currentTarget.dataset.mode);
  }

  #apply(mode) {
    const selected = mode === "inline" ? "inline" : "reference";

    if (this.hasModeFieldTarget) {
      this.modeFieldTarget.value = selected;
    }

    this.buttonTargets.forEach((button) => {
      const isActive = button.dataset.mode === selected;
      button.classList.remove(...(isActive ? this.#inactiveClasses : this.#activeClasses));
      button.classList.add(...(isActive ? this.#activeClasses : this.#inactiveClasses));
      button.setAttribute("aria-selected", isActive ? "true" : "false");
    });

    if (this.hasReferencePaneTarget) {
      this.referencePaneTarget.hidden = selected !== "reference";
    }
    if (this.hasInlinePaneTarget) {
      this.inlinePaneTarget.hidden = selected !== "inline";
    }
  }

  get #activeClasses() {
    return this.#classList("blockReferenceModeActive", "active");
  }

  get #inactiveClasses() {
    return this.#classList("blockReferenceModeInactive", "inactive");
  }

  #classList(datasetKey, fallback) {
    return (this.element.dataset[datasetKey] || fallback).split(" ").filter(Boolean);
  }
}
