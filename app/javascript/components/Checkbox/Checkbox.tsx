import React, { ReactNode } from "react"

interface CheckboxProps {
  checked: boolean
  onChange?: any
  children?: ReactNode
  inverted?: boolean
}

const Checkbox: React.FC<CheckboxProps> = ({
  checked,
  onChange,
  children,
  inverted = false
}) => (
  <label className="flex justify-start items-start">
    <div
      className={`border border-gray-400 rounded w-6 h-6 flex flex-shrink-0 justify-center items-center focus-within:border-blue-500 ${
        children ? " mr-2" : ""
      }`}
    >
      <input
        type="checkbox"
        className="opacity-0 absolute"
        onChange={onChange}
        checked={checked}
      />
      {checked && (
        <svg
          className={`fill-current w-4 h-4 text-gray-400 pointer-events-none ${inverted &&
            "inverted"}`}
          viewBox="0 0 20 20"
        >
          {!inverted && (
            <path d="M0,11.048l3,-3.548l4,5l10,-11l3,3.137l-13,13.89l-7,-7.479Z" />
          )}
          {inverted && (
            <>
              <clipPath id="_clip1">
                <path d="M20,20l-20,0l0,-20l20,0l0,20Zm-17,-9.291l4.9,5.129l9.1,-9.525l-2.1,-2.151l-7,7.543l-2.8,-3.429l-2.1,2.433Z" />
              </clipPath>
              <g clip-path="url(#_clip1)">
                <path d="M20,3.5c0,-1.932 -1.568,-3.5 -3.5,-3.5l-13,0c-1.932,0 -3.5,1.568 -3.5,3.5l0,13c0,1.932 1.568,3.5 3.5,3.5l13,0c1.932,0 3.5,-1.568 3.5,-3.5l0,-13Z" />
              </g>
            </>
          )}
        </svg>
      )}
    </div>
    {children && <div className="select-none">{children}</div>}
  </label>
)

export default Checkbox
