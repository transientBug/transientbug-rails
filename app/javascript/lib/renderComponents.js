import renderComponentsForSelector from "./renderComponentsForSelector";

const renderComponents = componentMap =>
  Object.entries(componentMap).forEach(([selector, component]) => {
    renderComponentsForSelector(selector, component);
  });

export default renderComponents;
