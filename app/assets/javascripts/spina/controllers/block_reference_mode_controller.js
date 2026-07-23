import { Controller } from "@hotwired/stimulus";

// Toggles a BlockReference part between "reference" (select a shared block)
// and "inline" (fill fields in on the page itself). The selected mode is
// carried by the checked radio button, whose name maps to the part's `mode`.
export default class extends Controller {
  static get targets() {
    return ["referencePane", "inlinePane"];
  }

  connect() {
    this.switch();
  }

  switch() {
    const mode = this.#selectedMode();
    if (this.hasReferencePaneTarget) {
      this.referencePaneTarget.hidden = mode !== "reference";
    }
    if (this.hasInlinePaneTarget) {
      this.inlinePaneTarget.hidden = mode !== "inline";
    }
  }

  #selectedMode() {
    const checked = this.element.querySelector(
      "input[type=radio][data-block-reference-mode-role=mode]:checked",
    );
    return checked ? checked.value : "reference";
  }
}
