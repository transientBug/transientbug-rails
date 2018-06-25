import { Button, Form } from "semantic-ui-react"

import { SubQuery } from "."

export const Query = (props) => (
  <Form className="qb query" action={ props.url } method={ props.method } onSubmit={ props.onSubmit }>
    <input type="hidden" value={ Rails.csrfToken() } name="authenticity_token" />
    <input type="hidden" value="✓" name="utf8" />

    <SubQuery { ...props } root="query" />

    <Button type="submit">Search</Button>
  </Form>
)
