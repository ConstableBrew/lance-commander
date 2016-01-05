"use strict";

window.ready ->
	unit = document.getElementById 'unit'
	variant = document.getElementById 'variant'
	pv = document.getElementById 'pv'
	tp = document.getElementById 'tp'
	sz = document.getElementById 'sz'
	tmm = document.getElementById 'tmm'
	mv = document.getElementById 'mv'
	role = document.getElementById 'role'
	skill = document.getElementById 'skill'
	short = document.getElementById 'short'
	medium = document.getElementById 'medium'
	long = document.getElementById 'long'
	ov = document.getElementById 'ov'
	structure = document.getElementById 'structure'
	armor = document.getElementById 'armor'
	special = document.getElementById 'special'

	movement = {} # Parsed movement values
	specials = {} # Parsed specials
	
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

	calculatePV = () ->
		parseMovement()
		parseSpecials()

		offensiveValue = do ->
			attackDamageFactor = (short.value | 0) + 2 * (medium.value | 0) + (long.value | 0)
			unitSizeFactor = if tp.value.uppercase is 'BM' or tp.value.uppercase is 'PM' then 0.5 * (sz.value | 0) else 0
			overHeatFactor = (if (ov.value | 0) > 0 then 1 else 0) + 0.5 * Math.max(ov.value | 0, 0)
			overHeatFactor *= 0.5 if (medium.value | 0) + (long.value | 0) is 0
			offensiveSpecialAbilityFactor = 0 # TODO
			blanketOffensiveModifier = 1 # TODO

			Math.ceil((attackDamageFactor + unitSizeFactor + overHeatFactor + offensiveSpecialAbilityFactor) * blanketOffensiveModifier * 2) / 2
		defensiveValue = do ->
			movementFactor = movement.values.reduce (a, b) -> if a > b/4 then a else b/4
			movementFactor /= 2 if movement.units is 'inches'
			movementFactor += 0.5 if movement['j']?
			movementFactor

		console.log offensiveValue, defensiveValue


	parseMovement = ->
		movement = {}
		moves = mv.value.split '/'
		moves[i] = {
			value: moves[i].match(/^\d+/)?[0] | 0
			mode: moves[i].match(/[a-z]$/i)?[0] || ''
		} for move, i in moves
		movement.values = (move.value for move in moves)
		(movement[move.mode] = move.value) for move in moves
		movement.units = if ~mv.value.indexOf '"' then 'inches' else 'hexes'
		console.log movement

	parseSpecials = ->
		specials = {}
		console.log specials



	scaleCard()
	window.addEventListener 'resize', scaleCard, false


	

	structureLabel = document.getElementById 'structureLabel'
	structurePipContainer = structure.parentNode
	fixupPips structurePipContainer
	structureLabel.addEventListener 'click', ->
		structure.value = (+structure.value | 0) + 1
		fixupPips structurePipContainer
	, false
	
	armorLabel = document.getElementById 'armorLabel'
	armorPipContainer = armorLabel.parentNode
	fixupPips armorPipContainer
	armorLabel.addEventListener 'click', ->
		armor.value = (+armor.value | 0) + 1
		fixupPips armorPipContainer
	, false

	(document.getElementById 'card').addEventListener 'click', calculatePV, false
