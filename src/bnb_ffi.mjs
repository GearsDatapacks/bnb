export function focusElement(id) {
  let element = document.getElementById(id);
  if (element === null) {
    return;
  }
  element.focus();
}

export function raf(callback) {
  requestAnimationFrame(callback);
}
