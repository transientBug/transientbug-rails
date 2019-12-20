import lodash from "lodash"

const classnames = (...args) =>
  lodash
    .chain(args)
    .flatten()
    .uniq()
    .filter(Boolean)
    .join(" ")
    .value()

export default classnames
