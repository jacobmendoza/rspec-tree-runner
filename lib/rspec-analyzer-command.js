/** @babel */
import EventEmitter from 'events';
import TerminalCommandRunner from './terminal-command-runner';
import path from 'path';

class RSpecAnalyzerCommand extends EventEmitter {
  constructor(terminalCommandRunner = new TerminalCommandRunner(), systemPath = path) {
    super();
    EventEmitter.call(this);

    this.terminalCommandRunner = terminalCommandRunner;
    this.path = systemPath;
  }
  run(file) {
    this.terminalCommandRunner.clean();

    const rubyPath = atom.config.get('rspec-tree-runner.rubyPathCommand');
    let rspecAnalyzerScript = atom.config.get('rspec-tree-runner.rspecAnalyzerScript');

    if (!rspecAnalyzerScript) {
      rspecAnalyzerScript = this.path.resolve(__dirname, '../spec-analyzer/spec_analyzer_script.rb');
    }

    const command = `${rubyPath} ${rspecAnalyzerScript} \"${file}\"`;

    this.terminalCommandRunner.onDataFinished((data) => this.parseData(data));

    this.terminalCommandRunner.run(command);
  }
  onDataParsed(callback) {
    // @emitter.on 'onDataParsed', callback
  }
  parseData(data) {
    this.emit('onDataParsed', data.stdOutData);
  }
}

module.exports = RSpecAnalyzerCommand;
