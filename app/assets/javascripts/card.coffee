"use strict";

window.ready ->
	scaleCard = ->
		card = document.getElementById 'card-container'

		cardWidth = 1050
		cardHeight = 750

		scaleX = window.innerWidth / cardWidth
		scaleY = window.innerHeight / cardHeight
		scale = Math.min scaleX, scaleY
		card.style.transform = 'scale(' + scale + ')'

	window.addEventListener 'resize', scaleCard, false
	scaleCard()
