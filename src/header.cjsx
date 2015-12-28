React = require('react/addons')
ReactRouter = require('react-router')
{Link} = ReactRouter

module.exports = React.createClass
	render: ->
		<div className="ui pointing menu">
			<div className="ui page grid">
				<div className="column" style={{paddingBottom: 0}}>
					<div className="title item">
						<b>Lance Commander</b>
					</div>
				</div>
			</div>
		</div>
