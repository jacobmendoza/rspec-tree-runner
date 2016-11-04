/** @babel */
import PluginStateStore from '../lib/plugin-state-store';
import TreeBuilder from '../lib/tree-builder';
import RSpecAnalyzerCommand from '../lib/rspec-analyzer-command';
import RSpecLauncherCommand from '../lib/rspec-launcher-command';
import StateBuilder from '../lib/state-builder';

//
// As the UI is intentionally coupled with the internal representation
// of the state class, this spec file will also know about that internal
// representation. This is temporal.
//
describe('PluginStateStore', () => {
	let sut;
	let rspecAnalyzerCommand;
	let rspecLauncherCommand;
	let stateBuilder;

	function assertErrorsNotDefined(state) {
		expect(state.rspecExecutionWarning).not.toBeDefined();
		expect(state.rspecExecutionError).not.toBeDefined();
		expect(state.parsingSpecError).not.toBeDefined();
	}

	beforeEach(() => {
		rspecAnalyzerCommand = new RSpecAnalyzerCommand();
		rspecLauncherCommand = new RSpecLauncherCommand();
		stateBuilder = new StateBuilder();

		spyOn(rspecAnalyzerCommand, 'run');
		spyOn(rspecLauncherCommand, 'run');

		sut = new PluginStateStore(
			new TreeBuilder(),
			rspecAnalyzerCommand,
			rspecLauncherCommand,
			stateBuilder);
	});

	describe('When no editor available', () => {
		let state;
		beforeEach(() => {
			sut.on('stateUpdated', newState => {
				state = newState;
			});
		});

		it('builds new default state with no editor', () => {
			runs(() => sut.set(null));
			waitsFor(() => state, 'new state has to be built', 100);
			runs(() => {
				expect(state.asTree).toEqual([]);
				expect(state.summary).not.toBeDefined();
				assertErrorsNotDefined(state);
			});
		});

		it('builds new default state with no buffer', () => {
			runs(() => sut.set({buffer: null}));
			waitsFor(() => state, 'new state has to be built', 100);
			runs(() => {
				expect(state.asTree).toEqual([]);
				expect(state.summary).not.toBeDefined();
				assertErrorsNotDefined(state);
			});
		});
	});

	describe('When editor available', () => {
		let state;
		let editor;
		beforeEach(() => {
			sut.on('stateUpdated', newState => {
				state = newState;
			});
		});

		describe('When spec file provided', () => {
			beforeEach(() => {
				editor = {
					buffer: {file: {path: '/Users/X/Repo/project-folder/spec/some_file_spec.rb'}},
					cursors: [{
						getBufferRow: () => 0
					}]
				};
				runs(() => sut.set(editor));
				waitsFor(() => state, 'new state has to be built', 100);
			});

			it('builds the new state for the editor', () => {
				runs(() => {
					expect(state.asTree).toEqual([]);
					expect(state.summary).not.toBeDefined();
					expect(state.loading).toBeFalsy();
					expect(state.file.path).toBe('/Users/X/Repo/project-folder/spec/some_file_spec.rb');
					assertErrorsNotDefined(state);
				});
			});

			describe('When running all tests', () => {
				beforeEach(() => {
					runs(() => sut.runTests());
				});

				it('builds new state', () => {
					runs(() => {
						expect(state.asTree).toEqual([]);
						expect(state.summary).not.toBeDefined();
						expect(state.loading).toBeTruthy();
						expect(state.file.path).toBe('/Users/X/Repo/project-folder/spec/some_file_spec.rb');
						assertErrorsNotDefined(state);
					});
				});

				it('calls the analyzer', () => {
					runs(() => expect(rspecAnalyzerCommand.run).toHaveBeenCalled());
				});
			});

			describe('When running just one test', () => {
				beforeEach(() => {
					runs(() => sut.runSingleTest());
				});

				it('builds new state', () => {
					runs(() => {
						expect(state.asTree).toEqual([]);
						expect(state.summary).not.toBeDefined();
						expect(state.loading).toBeTruthy();
						expect(state.file.path).toBe('/Users/X/Repo/project-folder/spec/some_file_spec.rb');
						assertErrorsNotDefined(state);
					});
				});

				it('calls the analyzer', () => {
					runs(() => expect(rspecAnalyzerCommand.run).toHaveBeenCalled());
				});
			});
		});
	});
});
