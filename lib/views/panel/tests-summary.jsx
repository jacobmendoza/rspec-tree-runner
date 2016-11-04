/** @babel */
import React from 'react';

const TestsSummary = React.createClass({
  render() {
    return (
      <div className='tests-summary'>
        <div className='tests-summary-container'>
          <div className='tests-summary-passed'>
            <div className='number'>{(this.props.summary ? <div>{this.props.summary.example_count - this.props.summary.failure_count}</div> : <div>-</div>)}</div>
            <div className='text'>passed</div>
          </div>
          <div className='tests-summary-failed'>
            <div className='number'>{(this.props.summary ? <div>{this.props.summary.failure_count}</div> : <div>-</div>)}</div>
            <div className='text'>failed</div>
          </div>
          <div className='tests-summary-pending'>
            <div className='number'>{(this.props.summary ? <div>{this.props.summary.pending_count}</div> : <div>-</div>)}</div>
            <div className='text'>pending</div>
          </div>
        </div>
      </div>
    );
  }
});

export default TestsSummary;
