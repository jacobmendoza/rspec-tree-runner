/** @babel */
import path from 'path';
import EventEmitter from 'events';
import TerminalCommandRunner from './terminal-command-runner';

const terminalCommandRunnerFactory = () => new TerminalCommandRunner();

class RSpecAnalyzerCommand extends EventEmitter {
	constructor(commandRunnerFactory = terminalCommandRunnerFactory, systemPath = path) {
		super();
		EventEmitter.call(this);

		this.path = systemPath;
		this.commandRunnerFactory = commandRunnerFactory;
	}

	run(file) {
		this.terminalCommandRunner = this.commandRunnerFactory();
		this.terminalCommandRunner.on('finishData', this.parseData.bind(this));

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
