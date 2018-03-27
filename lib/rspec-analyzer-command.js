/** @babel */
import path from 'path';
import EventEmitter from 'events';
import TerminalCommandRunner from './terminal-command-runner';

class RSpecAnalyzerCommand extends EventEmitter {
	constructor(terminalCommandRunner = new TerminalCommandRunner(), systemPath = path) {
		super();
		EventEmitter.call(this);

		this.terminalCommandRunner = terminalCommandRunner;
		this.path = systemPath;

		this.terminalCommandRunner.on('finishData', data => this.parseData(data));
	}

	run(file) {
		this.terminalCommandRunner.clean();

		const rubyPath = atom.config.get('rspec-tree-runner.rubyPathCommand');
		let rspecAnalyzerScript = atom.config.get('rspec-tree-runner.rspecAnalyzerScript');

		if (!rspecAnalyzerScript) {
			rspecAnalyzerScript = this.path.resolve(__dirname, '../spec-analyzer/spec_analyzer_script.rb');
		}

		const command = `${rubyPath} ${rspecAnalyzerScript} "${file}"`;

		this.terminalCommandRunner.run(command);
	}

	parseData(data) {
		this.emit('onDataParsed', {
			stdOutData: data.stdOutData,
			stdErrData: data.stdErrData
		});
	}
}

export default RSpecAnalyzerCommand;
