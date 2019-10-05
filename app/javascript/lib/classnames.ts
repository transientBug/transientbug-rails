import lodash from "lodash"

const classnames = (...args) =>
  lodash
    .chain(args)
    .flatten()
    .uniq()
    .join(" ")

export default classnames
