import { QueryBuilder } from "./components"
import { TextWidget, NumberWidget, DateWidget } from "./widgets"

const BuilderConfig = {
  "operations": {
    "[between]": { "display_name": "After til Before", "description": "", "composed_of": ["greater_than", "less_than"] },
    "[between)": { "display_name": "After til Before or On", "description": "", "composed_of": ["greater_than", "less_than_or_equal"] },
    "(between]": { "display_name": "On or After til Before", "description": "", "composed_of": ["greater_than_or_equal", "less_than"] },
    "(between)": { "display_name": "On or After til Before or On", "description": "", "composed_of": ["greater_than_or_equal", "less_than_or_equal"] },
    "less_than": { "display_name": "Less Than", "description": "" },
    "less_than_or_equal": { "display_name": "Less Than or Equal", "description": "" },
    "equal": { "display_name": "Equals", "description": "" },
    "greater_than_or_equal": { "display_name": "Greater Than or Equal", "description": "" },
    "greater_than": { "display_name": "Greater Than", "description": "" },
    "match": { "display_name": "Matches", "description": "" }
  },
  "types": {
    "text": {
      "supported_operations": [ "match" ],
      "widget": (props) => <TextWidget {...props} />
    },
    "keyword": {
      "supported_operations": [ "equal" ],
      "widget": (props) => <TextWidget {...props} />
    },
    "number": {
      "supported_operations": [ "[between]", "[between)", "(between]", "(between)", "less_than", "less_than_or_equal", "equal", "greater_than_or_equal", "greater_than" ],
      "widget": (props) => <NumberWidget {...props} />
    },
    "date": {
      "supported_operations": [ "[between]", "[between)", "(between]", "(between)", "less_than", "less_than_or_equal", "equal", "greater_than_or_equal", "greater_than" ],
      "widget": (props) => <DateWidget {...props} />
    },
  },
  "joiners": {
    "should": { "display_name": "Should", "description": "" },
    "must": { "display_name": "Must", "description": "" },
    "must_not": { "display_name": "Must Not", "description": "" }
  }
}

export const renderQueryBuilder = (selector) => {
  const appDiv = document.querySelector(selector)
  const fields = JSON.parse(appDiv.innerText)

  ReactDOM.render(<QueryBuilder config={ BuilderConfig } fields={ fields } />, appDiv)
}
