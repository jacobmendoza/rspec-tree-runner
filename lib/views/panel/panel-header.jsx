/** @babel */
import React from 'react';

const PanelHeader = React.createClass({
	render() {
		return (<h3 className='tree-view-title'>{this.props.fileName}</h3>)
	}
});

export default PanelHeader;
