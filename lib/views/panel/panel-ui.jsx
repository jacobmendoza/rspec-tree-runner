/** @babel */
import React from 'react';
import ReactDOM from 'react-dom';

import TestsSummary from './tests-summary.jsx';
import TestsContainer from './tests-container.jsx';
import HintsBlock from './hints-block.jsx'
import WrongFile from './wrong-file.jsx';

const PanelHeader = React.createClass({
  render() {
    return(<h3 className='tree-view-title'>{this.props.fileName}</h3>)
  }
});

const MainContainer = React.createClass({
  getInitialState() {
    return {
      file: {
        name:'',
        isSpecFile: () => false,
        isRubyFile: () => false
      },
      asTree: [],
      stdErrorData: undefined,
      summary: undefined,
      loading: false
    };
  },
  render() {
    let packageBody;
    if (this.state.parsingSpecError) {
      packageBody = (
        <div>
          <h2>Oops, something happened while reading the spec</h2>
          <h3>Error parsing the spec file</h3>
        </div>
      );
    } else if (this.state.rspecExecutionError) {
      packageBody = (
        <div>
          <h2>Oops, something happened while executing the spec</h2>
          <h3>Error when using RSpec over this file</h3>
        </div>
      );
    } else {
      packageBody = <TestsContainer state={this.state}/>;
    }

    if (this.state.file.isRubyFile() && this.state.file.isSpecFile()) {
      return (
        <div className="rspec-tree-runner">
          <div className='package-header'>rspec-tree-runner</div>
          <div className='subContainer'>
            <PanelHeader fileName={this.state.file.name}/>
            <TestsSummary summary={this.state.summary}/>
            <HintsBlock/>
            {packageBody}
          </div>
        </div>
      );
    }
    else {
      return(
        <div className="rspec-tree-runner">
          <div className='package-header'>rspec-tree-runner</div>
          <WrongFile file={this.state.file}/>
        </div>
      );
    }
  }
});

class PanelUI {
  constructor(element) {
    this.mainContainer = ReactDOM.render(<MainContainer/>, element);
  }

  updateState(newState) {
    this.mainContainer.setState(newState);
  }
}

module.exports = PanelUI;
