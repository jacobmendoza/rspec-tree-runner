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

		this.terminalCommandRunner.on('finishData', data => this.parseRSpecResult(data));
	}

	run(file) {
		this.terminalCommandRunner.clean();

		const rspecCommandPath = atom.config.get('rspec-tree-runner.rspecPathCommand');
		const command = `${rspecCommandPath} --format=json "${file}"`;

		let foundPath = null;
		const paths = atom.project.getPaths();

		for (let i = 0; i < paths.length; i++) {
			foundPath = paths[i];
			if (file.indexOf(foundPath) === 0) {
				break;
			}
		}

		if (foundPath) {
			this.terminalCommandRunner.run(command, foundPath);
		}
	}

	parseRSpecResult(data) {
		let jsonData;

		if (data && data.stdOutData) {
			jsonData = this.jsonExtractor.extract(data.stdOutData);
		}

		this.emit('onResultReceived', {
			stdOutData: jsonData,
			stdErrData: data.stdErrData
		});
	}
}

export default RSpecLauncherCommand;
