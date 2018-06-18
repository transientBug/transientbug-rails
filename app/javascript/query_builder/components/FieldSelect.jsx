import { entryMap } from "../utils"

export const FieldSelect = ({ value, onChange, fields }) => (
  <div className="field">
    <select className="ui dropdown" name={ name } value={ value } onChange={ onChange } disabled={ Object.keys(fields).length <= 1 }>
      { entryMap(fields, ([field, fieldData], i) => (
        <option key={ i } value={ field }>{ fieldData.display_name }</option>
      )) }
    </select>
  </div>
)
