/** @babel */
import React from 'react';

const HintsBlock = React.createClass({
  getInitialState() {
    const runTestsKeyBindings = atom.keymaps.findKeyBindings({command:'rspec-tree-runner:run-tests' });
    const runSingleTestKeyBindings = atom.keymaps.findKeyBindings({command:'rspec-tree-runner:run-single-test' });

    const runTestsKeyStroke = (runTestsKeyBindings && runTestsKeyBindings.length > 0) ? runTestsKeyBindings[0].keystrokes : 'not def';
    const runSingleTestKeyStroke = (runSingleTestKeyBindings && runSingleTestKeyBindings.length > 0) ? runSingleTestKeyBindings[0].keystrokes : 'not def';

    return {
      runTestsHint: `Press ${runTestsKeyStroke} to run tests`,
      runSingleTestHint: `Press ${runSingleTestKeyStroke} to run a single test`
    };
  },
  render() {
    return(
      <div className='panel-hints'>
        <h3 className='run-tests-hint hint'>{this.state.runTestsHint}</h3>
        <h3 className='run-single-test-hint hint'>{this.state.runSingleTestHint}</h3>
      </div>
    );
  }
});

module.exports = HintsBlock;
