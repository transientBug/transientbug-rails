import { Form } from "semantic-ui-react"

export const TextWidget = props => <Form.Input { ...props } />
export const NumberWidget = props => <Form.Input type="number" { ...props } />
export const DateWidget = props => <Form.Input type="date" { ...props } />
