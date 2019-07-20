import React, { Component } from "react";
import * as Mousetrap from "mousetrap";

import { isArray } from "lodash";

import Kbd from "../Kbd";

class KeyboardShortcut extends Component {
  constructor(props) {
    super(props);

    if (isArray(this.props.keys)) {
      this.keys = this.props.keys;
      this.displayKeys = this.props.keys;
    } else {
      this.keys = Object.keys(this.props.keys)[0];
      this.displayKeys = this.props.keys[this.keys];
    }

    Mousetrap.bind(this.keys, props.onKey);
  }

  componentWillUnmount() {
    Mousetrap.unbind(this.keys);
  }

  render = () => (
    <div className="key-combo">
      {this.displayKeys
        .map(key => (
          <Kbd key={key} dark>
            {key}
          </Kbd>
        ))
        .reduce((prev, curr) => [prev, " + ", curr])}
      {this.props.children}
    </div>
  );
}

export default KeyboardShortcut;
