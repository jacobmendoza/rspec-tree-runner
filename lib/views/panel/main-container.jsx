/** @babel */
import React from 'react';
import ReactDOM from 'react-dom';

import TestsSummary from './tests-summary.jsx';
import TestsContainer from './tests-container.jsx';
import HintsBlock from './hints-block.jsx'
import WrongFile from './wrong-file.jsx';
import InformationPopup from './information-popup.jsx';
import PanelHeader from './panel-header.jsx';

const MainContainer = React.createClass({
	componentDidMount() {
		const divElement = document.createElement('div');
		this.renderedElement = ReactDOM.render(<InformationPopup onCloseDetailWindow={this.closePopup}/>, divElement);
		this.testDetailsElement = atom.workspace.addModalPanel({item: divElement, visible:false});
	},
	closePopup() {
		this.testDetailsElement.hide();
	},
	openPopup(contents) {
		this.renderedElement.updateContents(contents);
		this.testDetailsElement.show();
	},
	openRSpecExecutionWarning() {
		this.openPopup({
			title: 'Warning executing RSpec',
			extendedText: this.state.rspecExecutionWarning
		})
	},
	openRSpecExecutionError() {
		this.openPopup({
			title: 'Error executing RSpec',
			extendedText: this.state.rspecExecutionError
		})
	},
	getInitialState() {
		return {
			file: {
				name:'',
				isSpecFile: () => false,
				isRubyFile: () => false
			},
			asTree: [],
			stdErrorData: undefined,
			summary: undefined,
			loading: false
		};
	},
	render() {
		let packageBody, executionErrorBlock;
		if (this.state.parsingSpecError) {
			packageBody = (
				<div>
					<h2>Oops, something happened while reading the spec</h2>
					<h3>Error parsing the spec file</h3>
				</div>
			);
		} else {
			packageBody = <TestsContainer state={this.state} openPopup={this.openPopup}/>;
		}

		if (this.state.rspecExecutionWarning) {
			executionErrorBlock = (
				<div className='executionErrorBlock'>
					<div className='warning' onClick={this.openRSpecExecutionWarning}>View RSpec execution warning</div>
				</div>
			);
		} else if (this.state.rspecExecutionError) {
			executionErrorBlock = (
				<div className='executionErrorBlock'>
					<div className='error' onClick={this.openRSpecExecutionError}>View RSpec execution error</div>
				</div>
			);
		}

		if (this.state.file.isRubyFile() && this.state.file.isSpecFile()) {
			return (
				<div className="rspec-tree-runner">
					<div id='subContainer' className='subContainer'>
						<PanelHeader fileName={this.state.file.name}/>
						<TestsSummary summary={this.state.summary}/>
						<HintsBlock/>
						{executionErrorBlock}
						{packageBody}
					</div>
				</div>
			);
		}
		else {
			return(
				<div className="rspec-tree-runner">
					<WrongFile file={this.state.file}/>
				</div>
			);
		}
	}
});

module.exports = MainContainer;
