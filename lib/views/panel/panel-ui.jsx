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
      file: { name:'', isValidSpecFile: () => false },
      asTree: [],
      stdErrorData: undefined,
      summary: undefined,
      loading: false
    };
  },
  render() {
    if (this.state.file.isValidSpecFile()) {
      return (
        <div className="rspec-tree-runner">
          <div className='package-header'>rspec-tree-runner</div>
          <div className='subContainer'>
            <PanelHeader fileName={this.state.file.name}/>
            <TestsSummary summary={this.state.summary}/>
            <HintsBlock/>
            <TestsContainer state={this.state}/>
          </div>
        </div>
      );
    }
    else {
      return(
        <div className="rspec-tree-runner">
          <div className='package-header'>rspec-tree-runner</div>
          <WrongFile/>
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
