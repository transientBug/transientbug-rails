import { Button, Form, List } from "semantic-ui-react"

import { SubQuery } from "."

export const Query = (props) => (
  <Form className="qb query" onSubmit={ props.onSubmit }>
    <SubQuery { ...props } />
    <Button type="submit">Search</Button>
  </Form>
)
