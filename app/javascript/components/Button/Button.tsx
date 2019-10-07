import React from "react"

interface ButtonProps {
  className?: string
  onClick?: any
}

const Button: React.FC<ButtonProps> = ({ className, onClick, children }) => {
  const style = [className, "button"]

  return (
    <button className={style.join(" ")} onClick={onClick}>
      {children}
    </button>
  )
}

export default Button
