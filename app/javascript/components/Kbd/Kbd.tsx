import React from "react";

interface KbdProps {
  children: string;
  dark: boolean;
}

const Kbd: React.FC<KbdProps> = props => (
  <kbd
    className={props.dark ? "dark" : ""}
    dangerouslySetInnerHTML={{ __html: props.children }}
  />
);

export default Kbd;
