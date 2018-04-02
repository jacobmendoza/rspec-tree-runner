/** @babel */
import EventEmitter from 'events';
import RSpecAnalyzerCommand from './rspec-analyzer-command';
import RSpecLauncherCommand from './rspec-launcher-command';
import TreeBuilder from './tree-builder';
import StateBuilder from './state-builder';
import getFile from './current-file';

class PluginStateStore extends EventEmitter {
	constructor(
		treeBuilder = new TreeBuilder(),
		rspecAnalyzerCommand = new RSpecAnalyzerCommand(),
		rspecLauncherCommand = new RSpecLauncherCommand(),
		stateBuilder = new StateBuilder()
	) {
		super();
		EventEmitter.call(this);

		this.treeBuilder = treeBuilder;
		this.rspecAnalyzerCommand = rspecAnalyzerCommand;
		this.rspecLauncherCommand = rspecLauncherCommand;
		this.stateBuilder = stateBuilder;

		this._wireCommandsEvents();

		this._currentState = this.stateBuilder.buildDefault();
	}

	set(editor, saving = false) {
		if (!editor || !editor.buffer) {
			this.setNullState();
			return;
		}

		this.editor = editor;

		if (!editor.buffer.file) {
			this._currentState = this.stateBuilder.buildDefault();
			this._emitNewState();
			return;
		}

		const filePath = editor.buffer.file.path;

		if (this._lastProcessedFile === filePath && !saving) {
			return;
		}

		this._currentState = this.stateBuilder
			.from(this._currentState)
			.withSummary(undefined)
			.withAsTree([])
			.withFile(getFile(filePath))
			.build();

		this._lastProcessedFile = filePath;

		this._emitNewState();

		if (this._currentState.file.isSpecFile()) {
			this._analyze(this._currentState.file.path);
		}
	}

	setNullState() {
		this._currentState = this.stateBuilder.buildDefault();
		this._emitNewState();
	}

	runTests() {
		if (!this._currentState.file || !this._currentState.file.isSpecFile()) {
			return;
		}

		this._currentState = this.stateBuilder
			.from(this._currentState)
			.loading(true)
			.build();

		this._emitNewState();

		this.rspecLauncherCommand.run(this._currentState.file.path);
	}

	runSingleTest() {
		if (!this._currentState.file || !this._currentState.file.isSpecFile()) {
			return;
		}

		this.cursor = this.editor.cursors[0];
		const specRowToAnalyze = this.cursor.getBufferRow() + 1;

		this._currentState = this.stateBuilder
			.from(this._currentState)
			.loading(true)
			.build();

		this._emitNewState();

		this.rspecLauncherCommand.run(this._currentState.file.path + ':' + specRowToAnalyze);
	}

	_updateTreeWithTests(executionResult) {
		const asTree = this.treeBuilder.updateWithTests(executionResult.stdOutData);

		this._currentState = this.stateBuilder
			.from(this._currentState)
			.withAsTree(asTree)
			.withRSpecExecutionWarning(executionResult.stdErrData)
			.loading(false)
			.withSummary(executionResult.stdOutData.summary)
			.build();

		this._emitNewState();
	}

	_analyze(file) {
		this.rspecAnalyzerCommand.run(file);
	}

	_wireCommandsEvents() {
		this.rspecAnalyzerCommand.on('onDataParsed', dataReceived => {
			if (dataReceived.stdErrData) {
				this._currentState = this.stateBuilder
					.from(this._currentState)
					.withSpecParsingError(dataReceived.stdErrData)
					.build();

				this._emitNewState();

				return;
			}

			const asTree = this.treeBuilder.buildFromStandardOutput(dataReceived.stdOutData);

			this._currentState = this.stateBuilder
				.from(this._currentState)
				.withAsTree(asTree)
				.build();

			this._emitNewState();
		});

		this.rspecLauncherCommand.on('onResultReceived', dataReceived => {
			if (dataReceived.stdErrData && !dataReceived.stdOutData) {
				this._currentState = this.stateBuilder
					.from(this._currentState)
					.loading(false)
					.withRSpecExecutionError(dataReceived.stdErrData)
					.build();

				this._emitNewState();

				return;
			}

			this._updateTreeWithTests(dataReceived);
		});
	}

	_emitNewState() {
		this.emit('stateUpdated', this._currentState);
	}
}

export default PluginStateStore;
