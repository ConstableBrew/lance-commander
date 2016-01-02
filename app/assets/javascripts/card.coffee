"use strict";

###
	when user clicks/hovers over canvas, find mouse coordinate and relate that back to 
	the DOM version of the card. Then display a canvas version of the input box and
	enable the user to enter values directly into

###

window.ready ->
	cardContainer = document.getElementById 'card-container'
	card = document.getElementById 'card'

	dataEntryContainer = document.getElementById 'data-entry-container'
	dataEntry = document.getElementById 'data-entry'
	dataLink = null

	canvas = document.getElementById 'canvas'
	context = canvas.getContext '2d'

	drawCardToCanvas = (message) ->
		# Move card DOM below viewport
		# Display the (non-visible) card DOM
		# Render the card DOM to the canvas
		# And then hide the card DOM again
		rect = canvas.getBoundingClientRect()
		cardContainer.style.top = window.outerHeight + 'px'
		cardContainer.style.display = ''

		# domvas clones the card DOM, so we need to properly set all the attributes so that the clone sees the latest data entry
		cardInputs = cardContainer.getElementsByTagName 'input'
		input.setAttribute('value', input.value) for input, i in cardInputs
		
		domvas.toImage card, ->
			#cardContainer.style.display = 'none'
			context.clearRect 0, 0, canvas.width, canvas.height
			context.drawImage @, 0, 0 
			if message?
				context.font = '20px Calibri'
				context.fillStyle = 'green'
				context.fillText message, 50, 40

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

	getCardDOMElementFromMouseCanvasPos = (event) ->
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
		cardContainer.style.display = 'none'
		return domElm

	handleMouseMove = (event) ->
		domElm = getCardDOMElementFromMouseCanvasPos event
		message = if domElm?.htmlFor? then domElm?.htmlFor else domElm?.id
		drawCardToCanvas message

	handleClick = (event) ->
		domElm = getCardDOMElementFromMouseCanvasPos event

		if domElm.htmlFor? and domElm.htmlFor != ''
			domElm = document.getElementById domElm.htmlFor

		if domElm.tagName is 'INPUT'
			dataLink = domElm
			cardContainer.style.display = ''
			canvasRect = canvas.getBoundingClientRect()
			domElmRect = domElm.getBoundingClientRect()
			sizeFactor = canvasRect.height / canvas.height
			domElmStyle = window.getComputedStyle(domElm, null)
			fontSize = parseFloat domElmStyle.getPropertyValue('font-size')
			fontWeight = parseFloat domElmStyle.getPropertyValue('font-weight')
			lineHeight = parseFloat domElmStyle.getPropertyValue('line-size')
			textAlign = domElmStyle.getPropertyValue 'text-align'

			dataEntry.value = domElm.value
			dataEntry.placeholder = domElm.placeholder
			dataEntry.style.width = (domElmRect.width * sizeFactor) + 'px'
			dataEntry.style.height = (domElmRect.height * sizeFactor) + 'px'
			dataEntry.style.fontSize = (fontSize * sizeFactor) + 'px'
			dataEntry.style.fontWeight = fontWeight
			dataEntry.style.lineHeight = (lineHeight * sizeFactor) + 'px'
			dataEntry.style.textAlign = textAlign
			
			dataEntryContainer.style.left = (domElmRect.left * sizeFactor + canvasRect.left) + 'px'
			dataEntryContainer.style.top = ((domElmRect.top - window.outerHeight) * sizeFactor + canvasRect.top) + 'px'
			dataEntryContainer.style.display = 'inline-block'
			cardContainer.style.display = 'none'

			dataEntry.focus()

	handleDataEntryBlur = (event) ->
		if dataLink?
			dataLink.value = dataEntry.value
			dataEntryContainer.style.display = 'none'
			drawCardToCanvas()			

	window.ready ->
		canvas.addEventListener 'mousemove', handleMouseMove, false
		canvas.addEventListener 'click', handleClick, false
		dataEntry.addEventListener 'blur', handleDataEntryBlur, false
		drawCardToCanvas()
