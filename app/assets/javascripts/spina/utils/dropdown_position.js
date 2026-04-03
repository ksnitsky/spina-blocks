// Positions an absolutely-positioned dropdown element above or below its
// container based on available viewport space.
//
// Usage:
//   import { positionDropdown } from "spina/utils/dropdown_position"
//   positionDropdown(this.dropdownTarget)
//
export function positionDropdown(dropdown) {
  const container = dropdown.parentElement
  const containerRect = container.getBoundingClientRect()
  const dropdownHeight = dropdown.offsetHeight
  const viewportHeight = window.innerHeight

  const spaceBelow = viewportHeight - containerRect.bottom
  const spaceAbove = containerRect.top

  if (spaceBelow < dropdownHeight && spaceAbove > spaceBelow) {
    // Not enough space below and more space above — show above
    dropdown.style.bottom = "100%"
    dropdown.style.top = "auto"
    dropdown.style.marginBottom = "4px"
    dropdown.style.marginTop = "0"
  } else {
    // Default: show below
    dropdown.style.bottom = "auto"
    dropdown.style.top = "100%"
    dropdown.style.marginTop = "4px"
    dropdown.style.marginBottom = "0"
  }
}
