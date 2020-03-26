import lodash from "lodash"

// prettier-ignore
const classnames = (...args) =>
  lodash
    .chain(args)
    .flatten()
    .uniq()
    .filter(Boolean)
    .join(" ")
    .value()

export default classnames
