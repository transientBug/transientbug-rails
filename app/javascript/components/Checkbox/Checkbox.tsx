import React, { ReactNode } from "react"

interface CheckboxProps {
  checked: boolean
  onChange?: any
  children?: ReactNode
}

const Checkbox: React.FC<CheckboxProps> = ({ checked, onChange, children }) => (
  <label className="flex justify-start items-start">
    <div className="bg-white border rounded border-gray-400 w-6 h-6 flex flex-shrink-0 justify-center items-center mr-2 focus-within:border-blue-500">
      <input
        type="checkbox"
        className="opacity-0 absolute"
        onChange={onChange}
        checked={checked}
      />
      {checked && (
        <svg
          className="fill-current w-4 h-4 text-black pointer-events-none"
          viewBox="0 0 20 20"
        >
          <path d="M0,11.048l3,-3.548l4,5l10,-11l3,3.137l-13,13.89l-7,-7.479Z" />
        </svg>
      )}
    </div>
    <div className="select-none">{children}</div>
  </label>
)

export default Checkbox
