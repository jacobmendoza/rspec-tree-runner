/** @babel */
import {TextEditor, CompositeDisposable} from 'atom';
import PluginStateStore from './plugin-state-store';

import PanelUI from './views/panel/panel-ui.jsx';

module.exports = {
	config: {
		specSearchPaths: {type: 'array', default: ['spec', 'fast_spec']},
		specDefaultPath: {type: 'string', default: 'spec'},
		rspecAnalyzerScript: {type: 'string', default: undefined},
		rubyPathCommand: {type: 'string', default: 'ruby'},
		rspecPathCommand: {type: 'string', default: 'rspec'},
		changeToSpecFileOnClick: {type: 'boolean', default: true},
		showRSpecWarningMessages: {type: 'boolean', default: true},
		sizeOfRSpecMessageStrings: {type: 'integer', default: 500}
	},
	rspecTreeRunnerView: null,
	initialized: false,
	subscriptions: null,
	activate() {
		this.panel = new PanelUI();
		window.addEventListener('resize', this.panel.resizeSubContainer, false);

		this.currentState = new PluginStateStore();
		this.currentState.on('stateUpdated', state => this.panel.updateState(state));

		this.subscriptions = new CompositeDisposable();
		this.subscriptions.add(
			atom.commands.add('atom-text-editor', 'buffer:saved', () => {
				const editor = atom.workspace.getActiveTextEditor();
				this.mainView.handleEditorEvents(editor);
			}),
			atom.commands.add('atom-workspace', 'rspec-tree-runner:toggle', () => atom.workspace.toggle(this.panel)),
			atom.commands.add('atom-workspace', 'rspec-tree-runner:toggle-spec-file', () => this.mainView.toggleSpecFile(this.currentState.currentCorrespondingFilePath)),
			atom.commands.add('atom-workspace', 'rspec-tree-runner:run-tests', () => this.currentState.runTests()),
			atom.commands.add('atom-workspace', 'rspec-tree-runner:run-single-test', () => this.currentState.runSingleTest())
		);
		atom.workspace.observeActivePaneItem(item => this.wireEventsForEditor(item));
	},
	wireEventsForEditor(item) {
		if (item instanceof TextEditor) {
			const currentBuffer = item.getBuffer();
			currentBuffer.onDidSave(() => this.currentState.set(item));
			this.currentState.set(item);
		} else {
			this.currentState.setNullState();
		}
	},
	deactivate() {
		this.modalPanel.destroy();
		this.subscriptions.dispose();
		this.rspecTreeRunnerView.destroy();
		window.removeEventListener('resize', this.resizeSubContainer, false);
	},
	serialize() {
	}
};
