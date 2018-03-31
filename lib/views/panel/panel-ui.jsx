/** @babel */
import React from 'react';
import ReactDOM from 'react-dom';

import MainContainer from './main-container.jsx';

class PanelUI {
	constructor() {
		this.element = document.createElement('div');
		this.mainContainer = ReactDOM.render(<MainContainer/>, this.element);
	}

	getTitle() {
		return 'rspec-tree-runner';
	}

	getURI () {
		return 'atom://rspec-tree-runner/panel';
	}

	getDefaultLocation() {
		return 'right';
	}

	getAllowedLocations() {
		return ['left', 'right'];
	}

	getPreferredWidth() {
		return 300;
	}

	resizeSubContainer() {
		// Quick fix implemented to allow the subContainer to have scroll when
		// the list of tests is big. I haven't been able to fix it just with CSS.
		const newHeight = window.innerHeight - 60;
		const subContainer = document.getElementById('subContainer');

		if (subContainer !== null) {
			subContainer.style.height = `${newHeight}px`;
		}
	}

	updateState(newState) {
		this.resizeSubContainer();
		this.mainContainer.setState(newState);
	}
}

module.exports = PanelUI;
