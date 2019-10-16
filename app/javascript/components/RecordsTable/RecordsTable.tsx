import React from "react"

import { upperCase } from "lodash"

const RecordsTable = ({ headers, records }) => (
  <table>
    <thead>
      <tr>
        {headers.map((header, idx) => (
          <th key={idx}>{upperCase(header)}</th>
        ))}
      </tr>
    </thead>
    <tbody>
      {records.map((record, ridx) => (
        <tr key={ridx}>
          {headers.map((header, idx) => (
            <td key={idx}>{record[header]}</td>
          ))}
        </tr>
      ))}
    </tbody>
  </table>
)

export default RecordsTable
