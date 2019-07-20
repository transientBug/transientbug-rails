import React, { useEffect, useState, useRef, ChangeEvent } from "react";

import KeyboardShortcut from "../KeyboardShortcut";
import Dropdown from "./Dropdown";

import * as styles from "./Search.module.scss";

interface SearchProps {
  query: string;
  path: string;
  placeholder: string;
}

const Search: React.FC<SearchProps> = ({
  query = "",
  path = "",
  placeholder = "Search Bookmarks ..."
}) => {
  const wrapperRef = useRef<HTMLDivElement>();
  const queryInputRef = useRef<HTMLInputElement>();
  const formRef = useRef<HTMLFormElement>();

  const submit = (e: Event) => {
    formRef.current.submit();
    e.preventDefault();
  };

  const [isOpen, setIsOpen] = useState(false);

  const open = (e: Event) => {
    setIsOpen(true);
    e.preventDefault();
  };

  const close = (e: Event) => {
    setIsOpen(false);
    e.preventDefault();
  };

  useEffect(() => {
    if (!isOpen) queryInputRef.current.blur();
    else queryInputRef.current.focus();
  }, [isOpen]);

  const handleOutsideClick = (e: MouseEvent) => {
    if (wrapperRef.current.contains(e.target as Node)) return;
    if (!isOpen) return;

    setIsOpen(false);
  };

  useEffect(() => {
    document.addEventListener("mousedown", handleOutsideClick, false);

    return () => {
      document.removeEventListener("mousedown", handleOutsideClick, false);
    };
  }, [handleOutsideClick]);

  const [queryInput, setQueryInput] = useState(query);
  const updateQuery = (e: ChangeEvent<HTMLInputElement>) =>
    setQueryInput(e.target.value);

  return (
    <div
      className={styles.search}
      onClick={() => setIsOpen(true)}
      ref={wrapperRef}
      role="searchbox"
      tabIndex={-1}
    >
      <div className={styles.navbarItem}>
        <div className={styles.input}>
          <form
            ref={formRef}
            className={styles.form}
            action={path}
            method="get"
          >
            <input
              ref={queryInputRef}
              value={queryInput}
              onChange={updateQuery}
              className={styles.searchInput}
              type="search"
              name="q"
              placeholder={placeholder}
            />
          </form>
        </div>
        <div className={styles.key}>
          <KeyboardShortcut keys={["/"]} onKey={open} />
        </div>
      </div>
      {isOpen && <Dropdown search={submit} close={close} />}
    </div>
  );
};

export default Search;
