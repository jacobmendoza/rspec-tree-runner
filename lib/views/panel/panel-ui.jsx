/** @babel */
import React from 'react';
import ReactDOM from 'react-dom';

import MainContainer from './main-container.jsx';

class PanelUI {
	constructor(element) {
		this.mainContainer = ReactDOM.render(<MainContainer/>, element);
	}

	updateState(newState) {
		this.mainContainer.setState(newState);
	}
}

module.exports = PanelUI;
