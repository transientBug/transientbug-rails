import QueryBuilder from "./components/QueryBuilder"
import { TextWidget, NumberWidget, DateWidget } from "./widgets"

const WidgetMap = {
  text: props => <TextWidget { ...props } />,
  keyword: props => <TextWidget { ...props } />,
  number: props => <NumberWidget { ...props } />,
  date: props => <DateWidget { ...props } />,
}

const renderQueryBuilder = (selector) => {
  const appDivs = document.querySelectorAll(selector)

  appDivs.forEach((appDiv) => {
    const query = JSON.parse(appDiv.dataset.query)
    const config = JSON.parse(appDiv.dataset.config)

    Object.keys(config.fields).forEach((key) => {
      const fieldType = config.fields[ key ].type

      config.fields[ key ].widget = WidgetMap[ fieldType ]
    })

    const parsedConfig = {
      query,
      config,
    }

    const props = Object.assign({}, appDiv.dataset, parsedConfig)

    ReactDOM.render(<QueryBuilder { ...props } />, appDiv, () => appDiv.classList.remove("hidden"))
  })
}

export default renderQueryBuilder
