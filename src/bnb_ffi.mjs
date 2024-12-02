import { Lazy } from "./lazy.mjs";

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

export function initLazy(lazy) {
  if (lazy.value === undefined) {
    lazy.value = lazy.initialiser();
  }
  return lazy.value;
}
