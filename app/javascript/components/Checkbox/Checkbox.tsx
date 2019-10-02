import React, { ReactNode } from "react"

interface CheckboxProps {
  checked: boolean
  onChange?: any
  children?: ReactNode
}

const Checkbox: React.FC<CheckboxProps> = ({ checked, onChange, children }) => (
  <label className="flex justify-start items-start">
    <div className="bg-white border-2 rounded border-gray-400 w-6 h-6 flex flex-shrink-0 justify-center items-center mr-2 focus-within:border-blue-500">
      <input
        type="checkbox"
        className="opacity-0 absolute"
        onChange={onChange}
        checked={checked}
      />
      <svg
        className={`fill-current ${
          checked ? "" : "hidden"
        } w-4 h-4 text-green-500 pointer-events-none`}
        viewBox="0 0 20 20"
      >
        <path d="M0 11l2-2 5 5L18 3l2 2L7 18z" />
      </svg>
    </div>
    <div className="select-none">{children}</div>
  </label>
)

export default Checkbox
