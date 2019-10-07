import React, { useEffect, useMemo } from "react"
import * as Mousetrap from "mousetrap"

import { zip } from "lodash"

import Kbd from "../Kbd"

import * as styles from "./KeyboardShortcut.module.scss"

interface KeyboardShortcutProps {
  keys: string[]
  displayKeys?: string[]
  onKey: EventHandlerNonNull
}

const KeyboardShortcut: React.FC<KeyboardShortcutProps> = ({
  keys,
  displayKeys,
  onKey,
  children
}) => {
  useEffect(() => {
    Mousetrap.bind(keys, onKey)

    return () => {
      Mousetrap.unbind(keys)
    }
  })

  const keyMap = useMemo(() => {
    const keyDisplayText =
      !displayKeys || displayKeys.length === 0 ? [...keys] : displayKeys

    return zip(keys, keyDisplayText)
  }, [keys, displayKeys])

  // TODO: the old version handled adding + signs between combos which typescript didn't like
  return (
    <span className={styles.keyCombo}>
      {keyMap.map(([key, display]) => (
        <Kbd key={key} dark>
          {display}
        </Kbd>
      ))}{" "}
      {children}
    </span>
  )
}

export default KeyboardShortcut
