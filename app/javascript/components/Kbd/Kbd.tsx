import React from "react"
import * as styles from "./Kbd.module.scss"

interface KbdProps {
  children: string
  dark?: boolean
}

const Kbd: React.FC<KbdProps> = ({ dark = true, children }) => (
  <kbd
    className={dark ? styles.dark : styles.light}
    dangerouslySetInnerHTML={{ __html: children }}
  />
)

export default Kbd
