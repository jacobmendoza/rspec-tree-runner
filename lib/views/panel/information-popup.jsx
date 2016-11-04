/** @babel */
import React from 'react';

const InformationPopup = React.createClass({
  getInitialState() {
    return { title: '', subTitle: '', extendedText: ''};
  },
  updateContents(contents) {
    this.setState(contents);
  },
  render() {
    return(
      <div className='rspec-test-details' >
        <h1>{this.state.title}</h1>
        <div className='message'>
          {this.state.subTitle}
          <div className='backtrace'>
            <div className='backtrace-text'>{this.state.extendedText}</div>
          </div>
          <button autofocus className='btn' onClick={this.props.onCloseDetailWindow}>Close</button>
        </div>
      </div>
    );
  }
});


export default InformationPopup;
