/** @babel */
import React from 'react';
import ReactDOM from 'react-dom';
import TreeView from 'react-treeview';

const LeafNode = React.createClass({
  openFailedTestPopup() {
    this.props.openPopup({
      title: 'Test details',
      subTitle: this.props.node.exception.message,
      extendedText: this.props.node.exception.backtrace
    });
  },
  render() {
    const node = this.props.node;
    if (node.withReport) {
      return(
        <div className={`test-${node.status}`}>
          <div className='test-text'>{node.text}</div>
          <div className='test-with-report' onDoubleClick={this.openFailedTestPopup}><span>&nbsp;</span></div>
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
          node.children.map(child => { return(<RecursiveTreeViewWrapper node={child} openPopup={this.props.openPopup} />); })
        }
        </TreeView>);
    } else {
      return(<LeafNode node={node} openPopup={this.props.openPopup} />);
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
    const containerStyle = (loading) ? 'loading' : ''; // { opacity: (!loading) ? '1' : '0.2' };
    const tree = this.props.state.asTree;
    if (tree.length > 0) {
      const parentNode = tree[0];
      return (
        <div className='tests-runner-container'>
          <LoadingIndicator activated={loading}/>
          <div className={containerStyle}>
            <RecursiveTreeViewWrapper node={parentNode} openPopup={this.props.openPopup}></RecursiveTreeViewWrapper>
          </div>
        </div>
      );
    } else {
      return (<div className='rspec-tree-runner-view-container'></div>);
    }
  }
});

export default TestsContainer;
