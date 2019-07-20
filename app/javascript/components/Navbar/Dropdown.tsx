import React from "react";

import KeyboardShortcut from "../KeyboardShortcut";

import * as styles from "./Dropdown.module.scss";

interface DropdownProps {
  close: any;
  search: any;
}

const Dropdown: React.FC<DropdownProps> = ({ close, search }) => {
  const getHelp = () => {
    console.log("help");
  };

  return (
    <div className={styles.dropdown}>
      <div className={styles.content}>
        Recent searches and saved searches coming soon!
      </div>
      <div className={styles.tips}>
        <div className={styles.left}>
          <KeyboardShortcut
            keys={["enter"]}
            displayKeys={["&crarr;"]}
            onKey={search}
          >
            Search
          </KeyboardShortcut>
        </div>
        <div className={styles.right}>
          <KeyboardShortcut keys={["?"]} onKey={getHelp}>
            Help
          </KeyboardShortcut>{" "}
          <KeyboardShortcut keys={["esc"]} onKey={close}>
            Close
          </KeyboardShortcut>
        </div>
      </div>
    </div>
  );
};

export default Dropdown;
