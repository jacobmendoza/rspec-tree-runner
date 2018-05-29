/** @babel */
import RSpecAnalyzerCommand from '../lib/rspec-analyzer-command';
import TerminalCommandRunner from '../lib/terminal-command-runner';

describe('RSpecAnalyzerCommand', () => {
	let fakePath;
	let terminalCommandRunner;
	let command;

	beforeEach(() => {
		fakePath = {resolve: {}};
		atom.config.set('rspec-tree-runner.rubyPathCommand', 'ruby');
		terminalCommandRunner = new TerminalCommandRunner();
		spyOn(terminalCommandRunner, 'run');
		command = new RSpecAnalyzerCommand(() => terminalCommandRunner, fakePath);
	});

	describe('If no analyzer path is supplied', () => {
		it('gets path from filesystem and calls runner', () => {
			atom.config.set('rspec-tree-runner.rspecAnalyzerScript', undefined);
			spyOn(fakePath, 'resolve').andReturn('route_to_script/spec_analyzer_script.rb');
			command.run('somefile');
			expect(terminalCommandRunner.run).toHaveBeenCalledWith('ruby route_to_script/spec_analyzer_script.rb "somefile"');
		});
	});

	describe('If analyzer path is supplied', () => {
		it('gets path from configuration and calls runner', () => {
			atom.config.set('rspec-tree-runner.rspecAnalyzerScript', 'custom_route/spec_analyzer_script.rb');
			command.run('somefile');
			expect(terminalCommandRunner.run).toHaveBeenCalledWith('ruby custom_route/spec_analyzer_script.rb "somefile"');
		});
	});
});
