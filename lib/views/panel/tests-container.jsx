/** @babel */
import React from 'react';
import ReactDOM from 'react-dom';
import TreeView from 'react-treeview';

const TestDetails = React.createClass({
  getInitialState() {
    return { message: '', backTrace: ''};
  },
  updateContents(message, backTrace) {
    this.setState({
      message: message,
      backTrace: backTrace
    });
  },
  render() {
    return(
      <div className='rspec-test-details' >
        <h1>Test details</h1>
        <div className='message'>
          {this.state.message}
          <div className='backtrace'>
            <div className='backtrace-text'>{this.state.backTrace}</div>
          </div>
          <button autofocus className='btn' onClick={this.props.onCloseDetailWindow}>Close</button>
        </div>
      </div>
    );
  }
});

const LeafNode = React.createClass({
  componentDidMount() {
    const divElement = document.createElement('div');
    this.renderedElement = ReactDOM.render(<TestDetails  onCloseDetailWindow={this.closeDetailWindow}/>, divElement);
    this.testDetailsElement = atom.workspace.addModalPanel({item: divElement, visible:false});
  },
  closeDetailWindow() {
    this.testDetailsElement.hide();
  },
  showError() {
    this.renderedElement.updateContents(
      this.props.node.exception.message,
      this.props.node.exception.backtrace);
    this.testDetailsElement.show();
  },
  render() {
    const node = this.props.node;
    if (node.withReport) {
      return(
        <div className={`test-${node.status}`}>
          <div className='test-text'>{node.text}</div>
          <div className='test-with-report' onDoubleClick={this.showError}><span>&nbsp;</span></div>
        </div>
      );
    } else {
      return(
        <div className={`test-${node.status}`}>
          <div className='test-text'>{node.text}</div>
        </div>
      );
    }
  }
});

const RecursiveTreeViewWrapper = React.createClass({
  render() {
    const node = this.props.node;
    if (node.children.length > 0) {
      return(
        <TreeView itemClassName={`test-${node.status}`} key={node.line} nodeLabel={node.text} defaultCollapsed={false}>
        {
          node.children.map(child => { return(<RecursiveTreeViewWrapper node={child}/>); })
        }
        </TreeView>);
    } else {
      return(<LeafNode node={node}/>);
    }
  }
});

const LoadingIndicator = React.createClass({
  render() {
    if (this.props.activated) {
      return (
        <div className='loading-indicator'>
            <div className="sk-three-bounce">
              <div className="sk-child sk-bounce1"></div>
              <div className="sk-child sk-bounce2"></div>
              <div className="sk-child sk-bounce3"></div>
            </div>
          </div>);
    } else {
      return(null);
    }
  }
});

const TestsContainer = React.createClass({
  render() {
    const loading = this.props.state.loading;
    const containerStyle = { opacity: (!loading) ? '1' : '0.2' };
    const tree = this.props.state.asTree;
    if (tree.length > 0) {
      const parentNode = tree[0];
      return (
        <div className='tests-runner-container'>
          <LoadingIndicator activated={loading}/>
          <div style={containerStyle}>
            <RecursiveTreeViewWrapper node={parentNode}></RecursiveTreeViewWrapper>
          </div>
        </div>
      );
    } else {
      return (<div className='rspec-tree-runner-view-container'></div>);
    }
  }
});

export default TestsContainer;
