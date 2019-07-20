import React from "react";
import ReactDOM from "react-dom";

import Navbar from "../components/Navbar";

const render = selector => {
  const appDivs = document.querySelectorAll(selector);

  appDivs.forEach(appDiv => {
    const props = { ...appDiv.dataset };

    ReactDOM.render(<Navbar {...props} />, appDiv);
  });
};

export default render;
