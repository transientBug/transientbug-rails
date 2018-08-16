export const Kbd = props => (
  <kbd className={ (props.dark ? "dark" : "") } dangerouslySetInnerHTML={ { __html: props.children } } />
)
