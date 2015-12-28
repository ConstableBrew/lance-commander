window.$ = window.jQuery = require('jquery')
require('semantic-ui-css/semantic')
React = require('react/addons')
ReactDOM = require('react-dom')
ReactRouter = require('react-router')
Header = require('./header')
UnitCard = require('./unit-card')

{Router, Route, IndexRoute} = ReactRouter

Home = React.createClass
	render: ->
		<div className="column">
			<div classNakme="ui segment">
				<h1 className="ui header">
					<span>Lance Commander</span>
					<div className="sub header">
						Create custom unit cards for BattleTech: Alpha Strike
					</div>
					<UnitCard name="Odin"/>
				</h1>
			</div>
		</div>

About = React.createClass
	render: ->
		<div className="column">
			<div className="ui segment">
				<h4 className="ui black header">This is the about page.</h4>
			</div>
		</div>

Main = React.createClass
	render: ->
		<div>
			<Header/>
			<div className="ui page grid">
				{ @props.children }
			</div>
		</div>

routes =
	<Route path="/" component={Main}>
		<IndexRoute component={Home}/>
		<Route path="about" component={About}/>
	</Route>

$ ->
	ReactDOM.render(<Router>{routes}</Router>, document.body)
