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
			unitSizeFactor = if tp.value.toUpperCase() is 'BM' or tp.value.toUpperCase() is 'PM' then 0.5 * (sz.value | 0) else 0
			overHeatFactor = (if (ov.value | 0) > 0 then 1 else 0) + 0.5 * Math.max((ov.value | 0) - 1, 0)
			overHeatFactor *= 0.5 if (medium.value | 0) + (long.value | 0) is 0
			offensiveSpecialAbilityFactor = 0 # TODO
			blanketOffensiveModifier = 1 # TODO

			console.log 'attackDamageFactor', attackDamageFactor,'unitSizeFactor', unitSizeFactor,'overHeatFactor', overHeatFactor,'offensiveSpecialAbilityFactor', offensiveSpecialAbilityFactor,'blanketOffensiveModifier', blanketOffensiveModifier
			Math.ceil((attackDamageFactor + unitSizeFactor + overHeatFactor + offensiveSpecialAbilityFactor) * blanketOffensiveModifier * 2) / 2
		defensiveValue = do ->
			movementFactor = movement.values.reduce (a, b) -> if a > b then a else b
			movementFactor /= 2 + (if movement.units is 'inches' then 2 else 0)
			movementFactor += 0.5 if movement['j']?
			defensiveSpecialAbilityFactor = 0 # TODO
			defensiveInteractionRating = do ->
				armorFactor = 2
				if tp.value.toUpperCase() is 'SV' or tp.value.toUpperCase() is 'CV'
					if movement['t'] or movement['s'] or movement['n']
						armorFactor = 1.8 
					else if movement['w'] or movement['h']
						armorFactor = 1.7
					else if movement['g'] or movement['v']
						armorFactor = 1.5
					if specials['ARS']
						armorFactor += 0.1
				if specials['BAR']
					armorFactor *= 0.5
				
				structureFactor = 1
				if tp.value.toUpperCase() is 'IM' or specials['BAR'] 
					structureFactor = 0.5
				else if tp.value.toUpperCase() is 'BA' or tp.value.toUpperCase() is 'CI'
					structureFactor = 2

				DIR_movementFactor = 0
				if movement['base'] <= 2 * (if movement.units is 'hexes' then 1 else 2)
					DIR_movementFactor += 0
				else if movement['base'] <= 4 * (if movement.units is 'hexes' then 1 else 2)
					DIR_movementFactor += 1
				else if movement['base'] <= 6 * (if movement.units is 'hexes' then 1 else 2)
					DIR_movementFactor += 2
				else if movement['base'] <= 9 * (if movement.units is 'hexes' then 1 else 2)
					DIR_movementFactor += 3
				else if movement['base'] <= 17 * (if movement.units is 'hexes' then 1 else 2)
					DIR_movementFactor += 4
				else if movement['base'] > 17 * (if movement.units is 'hexes' then 1 else 2)
					DIR_movementFactor += 5
				if movement['j']
					DIR_movementFactor += 1

				defenseFactor = DIR_movementFactor
				if tp.value.toUpperCase() is 'BA' or tp.value.toUpperCase() is 'PM'
					defenseFactor += 1
				if tp.value.toUpperCase() is 'CV' or tp.value.toUpperCase() is 'SV'
					if movement['v'] or movement['g']
						defenseFactor += 1
				if specials['LG'] or specials['VLG'] or specials['SLG']
					defenseFactor -= 1
				if specials['STL']
					defenseFactor += 2
				if (specials['MAS'] or specials['LMAS']) and DIR_movementFactor < 3
					defenseFactor += 3
				defenseFactor = Math.max(0, defenseFactor) / 10 + 1
				console.log 'defenseFactor',defenseFactor,'armor',armorFactor * (+armor.value | 0),'structure',structureFactor * (+structure.value | 0) 
				Math.ceil( defenseFactor * (armorFactor * (+armor.value | 0) + structureFactor * (+structure.value | 0)) * 2) / 2
			console.log 'movementFactor', movementFactor, 'defensiveSpecialAbilityFactor', defensiveSpecialAbilityFactor, 'defensiveInteractionRating', defensiveInteractionRating
			movementFactor + defensiveSpecialAbilityFactor + defensiveInteractionRating

		subTotal = offensiveValue + defensiveValue
		console.log 'OffensiveValue:', offensiveValue, 'defensiveValue:', defensiveValue, 'subtotal', subTotal
		# TODO Final PV modifiers 
		# TODO Force Bonuses
		return subTotal


	parseMovement = ->
		movement = {}
		moves = mv.value.split '/'
		moves[i] = {
			value: moves[i].match(/^\d+/)?[0] | 0
			mode: (moves[i].match(/[a-z]$/i)?[0] || '').toLowerCase()
		} for move, i in moves
		movement.values = (move.value for move in moves)
		(movement[move.mode] = move.value) for move in moves
		movement.base = movement.values[0]
		movement.units = if ~mv.value.indexOf '"' then 'inches' else 'hexes'

	parseSpecials = ->
		specials = {}
		specs = special.value.replace(/\(.*?\)/g,'').split ', '
		specs[i] = {
			value: specs[i].match(/\d*$/)?[0] | 0
			label: (specs[i].match(/^[a-z]*/i)?[0] || '').toUpperCase()
		} for spec, i in specs
		(specials[spec.label] = spec.value) for spec in specs
		console.log 'Specials', specials



	# Scale the card now and then later whenever the window size is changed
	scaleCard()
	window.addEventListener 'resize', scaleCard, false


	# Set up the click listener on the Structure label to add new pips
	structureLabel = document.getElementById 'structureLabel'
	structurePipContainer = structure.parentNode
	fixupPips structurePipContainer
	structureLabel.addEventListener 'click', ->
		# Remove a pip when a pip is clicked
		structure.value = (+structure.value | 0) + 1
		fixupPips structurePipContainer
	, false
	

	# Set up the click listener on the Armor label to add new pips
	armorLabel = document.getElementById 'armorLabel'
	armorPipContainer = armorLabel.parentNode
	fixupPips armorPipContainer
	armorLabel.addEventListener 'click', ->
		# Remove a pip when a pip is clicked
		armor.value = (+armor.value | 0) + 1
		fixupPips armorPipContainer
	, false

	# Calculate PV everytime the card is clicked
	(document.getElementById 'card').addEventListener 'click', ->
		pv.value = Math.max(1, Math.round(calculatePV()))
	, false
