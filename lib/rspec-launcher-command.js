/** @babel */
import EventEmitter from 'events';
import TerminalCommandRunner from './terminal-command-runner';
import JsonExtractor from './json-extractor';

class RSpecLauncherCommand extends EventEmitter {
  constructor(
    jsonExtractor = new JsonExtractor(),
    terminalCommandRunner = new TerminalCommandRunner()
  ) {
    super();
    EventEmitter.call(this);

    this.jsonExtractor = jsonExtractor;
    this.terminalCommandRunner = terminalCommandRunner;

    this.terminalCommandRunner.on('finishData', (data) => this.parseRSpecResult(data));
  }
  run(file) {
      this.terminalCommandRunner.clean();

      const rspecCommandPath = atom.config.get('rspec-tree-runner.rspecPathCommand');
      const command = `${rspecCommandPath} --format=json \"${file}\"`;

      this.terminalCommandRunner.run(command, atom.project.getPaths()[0]);
  }
  parseRSpecResult(data) {
    let jsonData = undefined;

    if (data && data.stdOutData) {
      jsonData = this.jsonExtractor.extract(data.stdOutData);
    }

    this.emit('onResultReceived', {
      stdOutData: jsonData,
      stdErrData: data.stdErrData
    });
  }
}

module.exports = RSpecLauncherCommand;
