import { Form } from "semantic-ui-react"

export const TextWidget = ({ value, onChange }) => <Form.Input value={ value } onChange={ onChange } />
export const NumberWidget = ({ value, onChange }) => <Form.Input type="number" value={ value } onChange={ onChange } />
export const DateWidget = ({ value, onChange }) => <Form.Input type="date" value={ value } onChange={ onChange } />
