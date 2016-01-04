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

	removePip = (pipContainer) ->
		pip = (pipContainer.getElementsByTagName 'div')?[0]
		if pip?
			pipContainer.removeChild pip

	addPip = (pipContainer) ->
		pip = document.createElement 'div'
		pip.classList.add 'pip'
		pipContainer.appendChild pip
		pip.addEventListener 'click', ->
			input = (pipContainer.getElementsByTagName 'input')?[0]
			input.value = (+input.value | 0) - 1
			fixupPips(pipContainer)
		, false

	fixupPips = (pipContainer) ->
		input = (pipContainer.getElementsByTagName 'input')?[0]
		pipsNeeded = +input.value | 0
		pipCount = (pipContainer.getElementsByTagName 'div')?.length | 0

		if pipsNeeded > pipCount
			addPip(pipContainer) while pipsNeeded > pipCount++
		else if pipsNeeded < pipCount
			removePip(pipContainer) while pipsNeeded < pipCount--



	scaleCard()
	window.addEventListener 'resize', scaleCard, false

	structureLabel = document.getElementById 'structureLabel'
	structurePipContainer = structure.parentNode
	fixupPips structurePipContainer
	structureLabel.addEventListener 'click', ->
		input = document.getElementById 'structure'
		input.value = (+input.value | 0) + 1
		fixupPips structurePipContainer
	, false
	
	armorLabel = document.getElementById 'armorLabel'
	armorPipContainer = armorLabel.parentNode
	fixupPips armorPipContainer
	armorLabel.addEventListener 'click', ->
		input = document.getElementById 'armor'
		input.value = (+input.value | 0) + 1
		fixupPips armorPipContainer
	, false

