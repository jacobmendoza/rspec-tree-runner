/** @babel */
import RSpecTreeView from './rspec-tree-view';
import {CompositeDisposable} from 'atom';
import PluginState from './plugin-state';

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
    this.pluginState = new PluginState();
    this.mainView = this.getView();
    this.subscriptions = new CompositeDisposable();
    this.subscriptions.add(
			atom.commands.add('atom-text-editor', 'buffer:saved', () => {
        const editor = atom.workspace.getActiveTextEditor();
        this.mainView.handleEditorEvents(editor);
      }),
      atom.commands.add('atom-workspace', 'rspec-tree-runner:toggle', () => this.mainView.toggle()),
      atom.commands.add('atom-workspace', 'rspec-tree-runner:toggle-spec-file', () => this.mainView.toggleSpecFile()),
      atom.commands.add('atom-workspace', 'rspec-tree-runner:run-tests', () => this.mainView.runTests()),
      atom.commands.add('atom-workspace', 'rspec-tree-runner:run-single-test', () => this.mainView.runSingleTest())
    );
  },
  runSingleTest() {
    this.pluginState.runSingleTest();
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
