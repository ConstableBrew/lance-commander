"use strict";

###
	when user clicks/hovers over canvas, find mouse coordinate and relate that back to 
	the DOM version of the card. Then display a canvas version of the input box and
	enable the user to enter values directly into

###

window.ready ->
	cardContainer = document.getElementById 'cardContainer'
	card = document.getElementById 'card'
	canvas = document.getElementById 'canvas'
	context = canvas.getContext '2d'

	dot = document.getElementById 'dot'

	drawCardToCanvas = (message) ->
		domvas.toImage card, ->
			context.clearRect 0, 0, canvas.width, canvas.height
			context.drawImage @, 0, 0 
			if message?
				#console.log message
				context.font = '20px Calibri'
				context.fillStyle = 'green'
				context.fillText message, 50, 40
			cardContainer.style.display = 'none'

	elementFromAbsolutePoint = (x, y) ->
		# Stash current Window Scroll
		scrollX = window.pageXOffset
		scrollY = window.pageYOffset
		# Scroll to element
		window.scrollTo x, y
		# Calculate new relative element coordinates
		newX = x - window.pageXOffset
		newY = y - window.pageYOffset
		# Grab the element 
		elm = document.elementFromPoint newX, newY
		# revert to the previous scroll location
		window.scrollTo scrollX, scrollY
		# returned the grabbed element at the absolute coordinates
		return elm

	getMouseCanvasPos = (canvas, event) ->
		rect = canvas.getBoundingClientRect()
		return {
			x: event.clientX - rect.left
			y: event.clientY - rect.top
			width: rect.width
			height: rect.height
		}

	handleMouse = (event) ->
		# Get the mouse's position over the canvas
		# Calculate the relative position to the actual card
		# Display the actual card below the view fold
		# Get the element under the mouseposition on the actual card
		# Then hide the actual card
		mousePos = getMouseCanvasPos canvas, event
		domPos = {
			x: mousePos.x / mousePos.width * canvas.width
			y: mousePos.y / mousePos.height * canvas.height + window.outerHeight
		}

		cardContainer.style.top = window.outerHeight + 'px'
		cardContainer.style.display = ''
		domElm = elementFromAbsolutePoint domPos.x, domPos.y

		message = if domElm?.htmlFor? then domElm?.htmlFor else domElm?.id
		drawCardToCanvas message

	window.ready ->
		rect = canvas.getBoundingClientRect()
		cardContainer.style.top = window.outerHeight + 'px'
		canvas.addEventListener 'mousemove', handleMouse, false
		drawCardToCanvas()
