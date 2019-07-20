import React from "react";
import ReactDOM from "react-dom";

const renderComponentsForSelector = (selector, Component) => {
  const appDivs = document.querySelectorAll(selector);

  appDivs.forEach(appDiv => {
    const props = { ...appDiv.dataset };

    ReactDOM.render(<Component {...props} />, appDiv);
  });
};

export default renderComponentsForSelector;
