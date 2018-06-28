import { Dropdown, Header } from "semantic-ui-react"

const GrouperHeader = ({ data, addClause, addGroup }) => (
  <Header>
    { data.display_name }
    <Dropdown>
      <Dropdown.Menu>
        <Dropdown.Item text="Add Clause" icon="plus" onClick={ addClause } />
        <Dropdown.Item text="Add Nested Group" icon="plus" onClick={ addGroup } />
      </Dropdown.Menu>
    </Dropdown>
  </Header>
)

export default GrouperHeader
