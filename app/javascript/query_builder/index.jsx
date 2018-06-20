import { QueryBuilder } from "./components"
import { TextWidget, NumberWidget, DateWidget } from "./widgets"

const WidgetMap = {
  text: (props) => <TextWidget {...props} />,
  keyword: (props) => <TextWidget {...props} />,
  number: (props) => <NumberWidget {...props} />,
  date: (props) => <DateWidget {...props} />
}

export const renderQueryBuilder = (selector) => {
  const appDiv = document.querySelector(selector)
  const config = JSON.parse(appDiv.innerText)
  Object.assign(config, appDiv.dataset)

  ReactDOM.render(<QueryBuilder widgetMap={ WidgetMap } { ...config } />, appDiv)
}
