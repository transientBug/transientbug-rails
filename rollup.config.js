import resolve from "@rollup/plugin-node-resolve"
import replace from '@rollup/plugin-replace'

const debug = process.env.ROLLUP_WATCH

export default {
  input: "app/javascript/application.js",
  output: {
    file: "app/assets/builds/application.js",
    format: "es",
    inlineDynamicImports: true,
    sourcemap: true
  },
  plugins: [
    replace({
      preventAssignment: true,
      "process.env.debug": debug
    }),
    resolve()
  ]
}
