export const walk = (
  el: Element,
  callback: (el: Element) => void | null | boolean
) => {
  if (callback(el) === false) return

  let node = el.firstElementChild

  while (node) {
    walk(node, callback)

    node = node.nextElementSibling
  }
}
