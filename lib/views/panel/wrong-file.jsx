/** @babel */
import React from 'react';

const WrongFile = React.createClass({
  render() {
    let title, subtitle;

    if (!this.props.file.isRubyFile()) {
      title = 'It seems that this is not a ruby file';
      subtitle = 'The file must have the extension .rb';
    } else if (!this.props.file.isSpecFile()) {
      title = 'It seems that this is not a spec file';
      subtitle = 'I can only show the tree and execute tests over spec files with a name ending in \'_spec.rb;\'';
    }

    return(
      <div className='wrong-type-file'>
        <h2>{title}</h2>
        <h3>{subtitle}</h3>
      </div>
    );
  }
});

export default WrongFile;
