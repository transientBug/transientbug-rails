import { Button, Form, List } from "semantic-ui-react"

import { SubQuery } from "."

export const Query = (props) => (
  <Form className="qb query" action={ props.url } method={ props.method } onSubmit={ props.onSubmit }>
    <Form.Input type='hidden' value={ Rails.csrfToken() } name='authenticity_token' />
    <Form.Input type='hidden' value="✓" name='utf8' />
    <SubQuery { ...props } root="query" />
    <Button type="submit">Search</Button>
  </Form>
)
