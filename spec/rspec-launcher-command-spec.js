/** @babel */
import RSpecLauncherCommand from '../lib/rspec-launcher-command';
import JsonSanitizer from '../lib/json-extractor';
import TerminalCommandRunner from '../lib/terminal-command-runner';

describe('RSpecLauncherCommand', () => {
	let terminalCommandRunner;
	let rspecLauncherCommand;
	let jsonSanitizer;

	beforeEach(() => {
		spyOn(atom.project, 'getPaths').andReturn(['a', 'b']);
		atom.config.set('rspec-tree-runner.rspecPathCommand', 'rspec');

		jsonSanitizer = new JsonSanitizer();
		terminalCommandRunner = new TerminalCommandRunner();

		spyOn(terminalCommandRunner, 'run');
		spyOn(jsonSanitizer, 'extract').andReturn({});

		rspecLauncherCommand = new RSpecLauncherCommand(
			jsonSanitizer, () => terminalCommandRunner);

		rspecLauncherCommand.parseRSpecResult({stdOutData: '{}', stdErrorData: ''});
	});

	it('runs the command on project a', () => {
		rspecLauncherCommand.run('a/somefile');

		expect(terminalCommandRunner.run)
			.toHaveBeenCalledWith('rspec --format=json "a/somefile"', 'a');
	});

	it('runs the command on project b', () => {
		rspecLauncherCommand.run('b/somefile');

		expect(terminalCommandRunner.run)
			.toHaveBeenCalledWith('rspec --format=json "b/somefile"', 'b');
	});

	it('calls the sanitizer when parsing data', () => {
		expect(jsonSanitizer.extract)
			.toHaveBeenCalledWith('{}');
	});
});
