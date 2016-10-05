/** @babel */
import React from 'react';

const WrongFile = React.createClass({
  render() {
    return (
      <div className='wrong-type-file'>
        <h2>It seems that this is not a ruby file</h2>
        <h3>The file must have the extension .rb</h3>
      </div>
    );
  }
});

export default WrongFile;
