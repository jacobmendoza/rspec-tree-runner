/** @babel */
import RSpecTreeView from './views/rspec-tree-view';
import {CompositeDisposable} from 'atom';
import PluginState from './plugin-state';
import RailsRSpecFinder from './rails-rspec-finder';
import {TextEditor} from 'atom';

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
  mainView: null,
  subscriptions: null,
  activate() {
    this.currentState = new PluginState();
    this.railsRSpecFinder = new RailsRSpecFinder();

    this.currentState.on('onTreeBuilt', (result) => {
      this.view.setStdErrorNotification(result);
      this.view.redrawTree(result.asTree, result);
    });

    this.currentState.on('onSpecFileBeingAnalyzed', () => this.view.displayLoadingMessage('Spec file being analyzed'));
    this.currentState.on('onTestsRunning', () => this.view.displayLoadingMessage('RSpec running tests'));

    this.mainView = this.getView();
    this.subscriptions = new CompositeDisposable();
    this.subscriptions.add(
			atom.commands.add('atom-text-editor', 'buffer:saved', () => {
        const editor = atom.workspace.getActiveTextEditor();
        this.mainView.handleEditorEvents(editor);
      }),
      atom.commands.add('atom-workspace', 'rspec-tree-runner:toggle', () => this.mainView.toggle()),
      atom.commands.add('atom-workspace', 'rspec-tree-runner:toggle-spec-file', () => this.mainView.toggleSpecFile(this.currentState.currentCorrespondingFilePath)),
      atom.commands.add('atom-workspace', 'rspec-tree-runner:run-tests', () => this.runTests()),
      atom.commands.add('atom-workspace', 'rspec-tree-runner:run-single-test', () => this.runSingleTest())
    );
    atom.workspace.observeActivePaneItem((item) => this.wireEventsForEditor(item));
  },
  wireEventsForEditor(item) {
    if (item instanceof TextEditor) {
      this.handleEditorEvents(item);
    } else {
      this.view.setUiForNonRubyFileMessage();
    }
  },
  handleEditorEvents(editor) {
    const currentBuffer = this.tryGetBufferFrom(editor);
    if (currentBuffer) {
      currentBuffer.onDidSave(() => {
        if (this.railsRSpecFinder.isSpec(currentBuffer.file.path)) {
          this.setCurrentAndCorrespondingFile(editor);
        }
      });
    }
    if (editor) {
      this.setCurrentAndCorrespondingFile(editor);
    } else {
      this.view.hide();
    }
  },
  setCurrentAndCorrespondingFile(editor) {
    this.view.show();

    this.currentState.set(editor);

    this.view.setInitialUI();

    if (this.currentState.currentFilePathExtension !== 'rb') {
      this.view.setUiForNonRubyFileMessage();
      return;
    }

    this.view.setUiForRubyFile(this.currentState.currentFileName);

    if (this.currentState.specFileExists) {
      this.view.setUiForSpecFileExists();
    } else {
      this.view.setUiForSpecFileNotExists();
    }
  },
  tryGetBufferFrom(editor) {
    try {
      return editor.getBuffer();
    } catch(e) {
      return undefined;
    }
  },
  runTests() {
    if (this.currentState.specFileExists) {
      this.currentState.runTests();
    }
  },
  runSingleTest() {
    if (this.currentState.specFileExists) {
      this.currentState.runSingleTest();
    }
  },
  deactivate() {
    this.modalPanel.destroy();
    this.subscriptions.dispose();
    this.rspecTreeRunnerView.destroy();
  },
  serialize() {
  },
  getView() {
    if (!this.view) {
      this.view = new RSpecTreeView();
      this.view.attach();
    }
    return this.view;
  }
};
