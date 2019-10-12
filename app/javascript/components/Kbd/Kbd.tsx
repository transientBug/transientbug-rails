import React from "react"
import * as styles from "./Kbd.module.scss"

interface KbdProps {
  children: string
  dark: boolean
}

const Kbd: React.FC<KbdProps> = props => (
  <kbd
    className={props.dark ? styles.dark : styles.light}
    dangerouslySetInnerHTML={{ __html: props.children }}
  />
)

export default Kbd
