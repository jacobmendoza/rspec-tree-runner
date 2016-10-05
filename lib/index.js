/** @babel */
import {CompositeDisposable} from 'atom';
import PluginStateStore from './plugin-state-store';
import {TextEditor} from 'atom';

import PanelUI from './views/panel/panel-ui.jsx';

module.exports = {
  config: {
    specSearchPaths:            { type: 'array',    default: ['spec', 'fast_spec'] },
    specDefaultPath:            { type: 'string',   default: 'spec' },
    rspecAnalyzerScript:        { type: 'string',   default: undefined },
    rubyPathCommand:            { type: 'string',   default: 'ruby' },
    rspecPathCommand:           { type: 'string',   default: 'rspec' },
    changeToSpecFileOnClick:    { type: 'boolean',  default: true},
    showRSpecWarningMessages:   { type: 'boolean',  default: true},
    sizeOfRSpecMessageStrings:  { type: 'integer',  default: 500}
  },
  rspecTreeRunnerView: null,
  initialized: false,
  subscriptions: null,
  activate() {
    this.initializeView();
    this.currentState = new PluginStateStore();
    this.currentState.on('stateUpdated', (state) => this.panel.updateState(state));
    this.subscriptions = new CompositeDisposable();

    this.subscriptions.add(
			atom.commands.add('atom-text-editor', 'buffer:saved', () => {
        const editor = atom.workspace.getActiveTextEditor();
        this.mainView.handleEditorEvents(editor);
      }),
      atom.commands.add('atom-workspace', 'rspec-tree-runner:toggle', () => this.toggle()),
      atom.commands.add('atom-workspace', 'rspec-tree-runner:toggle-spec-file', () => this.mainView.toggleSpecFile(this.currentState.currentCorrespondingFilePath)),
      atom.commands.add('atom-workspace', 'rspec-tree-runner:run-tests', () => this.currentState.runTests()),
      atom.commands.add('atom-workspace', 'rspec-tree-runner:run-single-test', () => this.currentState.runSingleTest())
    );
    atom.workspace.observeActivePaneItem((item) => this.wireEventsForEditor(item));
  },
  wireEventsForEditor(item) {
    if (item instanceof TextEditor) {
      this.handleEditorEvents(item);
    } else {
      this.currentState.setNullState();
    }
  },
  handleEditorEvents(editor) {
    const currentBuffer = editor.getBuffer();
    currentBuffer.onDidSave(() => {
      if (this.currentState.state.file.isValidSpecFile()) {
        this.currentState.set(editor);
      }
    });
    this.currentState.set(editor);
  },
  deactivate() {
    this.modalPanel.destroy();
    this.subscriptions.dispose();
    this.rspecTreeRunnerView.destroy();
  },
  serialize() {
  },
  toggle() {
    if (!this.initialized) {
      //This part needs to be reviewed.
      //Using this as toggle is both used as toggling and activation event.
      this.initialized = true;
      return;
    }

    if (this.view.isVisible()) {
      this.view.hide();
    } else {
      this.view.show();
    }
  },
  initializeView() {
    this.element = document.createElement('div');
    this.panel = new PanelUI(this.element);
    this.view = atom.workspace.addRightPanel({item: this.element, visible: true});
    this.view.show();
  }
};
