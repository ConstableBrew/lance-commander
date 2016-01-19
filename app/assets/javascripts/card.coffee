"use strict";

window.ready ->
	card = document.getElementById 'card-container'
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
			offensiveSpecialAbilityFactor = 0
			offensiveSpecialAbilityFactor += +(offensiveSpecialAbilityFactors[spec]?(rating)) || 0 for spec, rating of specials
			blanketOffensiveModifier = 1
			blanketOffensiveModifier += if (tp.value is 'IM' or tp.value is 'SV') and not (specials['AFC']? or specials['BFC']?) then -0.2 else 0
			blanketOffensiveModifier += if (
				specials['C3BSI']? or 
				specials['C3BSM']? or 
				specials['C3BSS']? or 
				specials['C3EM']? or 
				specials['C3M']? or 
				specials['C3S']? or 
				specials['C3I']?
			) then 0.1 else 0
			blanketOffensiveModifier += +(blanketOffensiveModifiers[spec]?(rating)) || 0 for spec, rating of specials

			console.log 'attackDamageFactor', attackDamageFactor,
				'unitSizeFactor', unitSizeFactor,
				'overHeatFactor', overHeatFactor,
				'offensiveSpecialAbilityFactor', offensiveSpecialAbilityFactor,
				'blanketOffensiveModifier', blanketOffensiveModifier
			Math.ceil((attackDamageFactor + unitSizeFactor + overHeatFactor + offensiveSpecialAbilityFactor) * blanketOffensiveModifier * 2) / 2
		defensiveValue = do ->
			movementFactor = movement.best
			movementFactor /= 2 + (if movement.units is 'inches' then 2 else 0)
			movementFactor += 0.5 if movement['j']?
			defensiveSpecialAbilityFactor = 0
			defensiveSpecialAbilityFactor += +(defensiveSpecialAbilityFactors[spec]?(rating)) || 0 for spec, rating of specials
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
				if movement.best <= 2 * (if movement.units is 'hexes' then 1 else 2)
					DIR_movementFactor += 0
				else if movement.best <= 4 * (if movement.units is 'hexes' then 1 else 2)
					DIR_movementFactor += 1
				else if movement.best <= 6 * (if movement.units is 'hexes' then 1 else 2)
					DIR_movementFactor += 2
				else if movement.best <= 9 * (if movement.units is 'hexes' then 1 else 2)
					DIR_movementFactor += 3
				else if movement.best <= 17 * (if movement.units is 'hexes' then 1 else 2)
					DIR_movementFactor += 4
				else if movement.best > 17 * (if movement.units is 'hexes' then 1 else 2)
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
				Math.ceil( defenseFactor * (armorFactor * (armor.value | 0) + structureFactor * (structure.value | 0)) * 2) / 2
			console.log 'movementFactor', movementFactor, 
				'defensiveSpecialAbilityFactor', defensiveSpecialAbilityFactor, 
				'defensiveInteractionRating', defensiveInteractionRating
			movementFactor + defensiveSpecialAbilityFactor + defensiveInteractionRating

		subTotal = offensiveValue + defensiveValue

		speedAndRangeFactor = 1
		if (not specials['ARTAIS']? and
			not specials['ARTAC']? and
			not specials['ARTT']? and
			not specials['ARTLT']? and
			not specials['ARTBA']? and
			not specials['ARTTC']? and
			not specials['ARTSC']? and
			not specials['ARTLTC']? and
			not specials['BT']? and
			movement.best > 0 and
			(long.value | 0) is 0
			# TODO: Include logic for "and if unit is armed"
		)
			if movement.best < 3 * (if movement.units is 'hexes' then 1 else 2)
				if (medium.value | 0) is 0
					speedAndRangeFactor = 0.5
				else
					speedAndRangeFactor = 0.75
			else if movement.best <= 5 * (if movement.units is 'hexes' then 1 else 2)
				if (medium.value | 0) is 0
					speedAndRangeFactor = 0.75

		
		forceBonus = 0
		forceBonus += +(forceBonuses[spec]?(rating)) || 0 for spec, rating of specials


		console.log 'OffensiveValue:', offensiveValue, 
			'defensiveValue:', defensiveValue,
			'subtotal', subTotal
			'speedAndRangeFactor', speedAndRangeFactor
			'forceBonus', forceBonus

		Math.max(1, Math.round(speedAndRangeFactor * subTotal + forceBonus))
	
	calculateTMM = ->
		tmmString = for speed, i in movement.values
			if speed <= 2 * (if movement.units is 'hexes' then 1 else 2)
				tmmValue = 0
			else if speed <= 4 * (if movement.units is 'hexes' then 1 else 2)
				tmmValue = 1
			else if speed <= 6 * (if movement.units is 'hexes' then 1 else 2)
				tmmValue = 2
			else if speed <= 9 * (if movement.units is 'hexes' then 1 else 2)
				tmmValue = 3
			else if speed <= 17 * (if movement.units is 'hexes' then 1 else 2)
				tmmValue = 4
			else if speed > 17 * (if movement.units is 'hexes' then 1 else 2)
				tmmValue = 5
			if movement['j']
				tmmValue += 1
			tmmValue + if movement.modes[i] then movement.modes[i] else ''
		tmmString.join('/')

	parseMovement = ->
		movement = {}
		moves = mv.value.split '/'
		moves[i] = {
			value: moves[i].match(/^\d+/)?[0] | 0
			mode: (moves[i].match(/[a-z]$/i)?[0] || '').toLowerCase()
		} for move, i in moves
		movement.values = (move.value for move in moves)
		movement.modes = (move.mode for move in moves)
		(movement[move.mode] = move.value) for move in moves
		movement.base = movement.values[0]
		movement.units = if ~mv.value.indexOf '"' then 'inches' else 'hexes'
		movement.best = Math.max.apply null, movement.values

	parseSpecials = ->
		specials = {}
		specs = special.value.toUpperCase().replace(/\(.*?\)/g,'').split ', '
		specs = ({
			rating: spec.match(/(\d+(?![a-z]))/gi)
			label: (spec.match(/^(c3)?[a-z]*/i)?[0] || '').toUpperCase()
		} for spec, i in specs)
		spec.rating = (if spec.rating?[1]? then [
			spec.rating[0] | 0
			spec.rating[1] | 0
			spec.rating[2] | 0
		] else (if spec.rating? then (spec.rating?[0] | 0) else 0)) for spec, i in specs
		(specials[spec.label] = spec.rating) for spec in specs
	
	doCalculations = ->
		console.info 'Doing calculations...'

		pvSkillRating = [2.63, 2.24, 1.82, 1.38, 1, 0.86, 0.77, 0.68] # AS Pg. 167 "POINT VALUE SKILL RATING TABLE"
		skillRating = if parseInt(skill.value, 10) != (skill.value | 0) then 4 else (skill.value | 0) # scrub the skill input
		skillRating = if pvSkillRating[skillRating]? then skillRating else 4
		skill.value = skillRating

		basePV = Math.max(1, Math.round(calculatePV()))
		finalPV = Math.max(1, Math.round(basePV * pvSkillRating[skillRating])) # Adjust PV for pilot skill rating
		finalPV = if isNaN(finalPV) then '?' else finalPV
		pv.value = finalPV

		tmm.value = calculateTMM()


	offensiveSpecialAbilityFactors = {
		# using advanced rules artillery damage values
		ARTAIS: (rating) -> 3 * 4 * rating
		ARTAC: (rating) -> 3 * 4 * rating
		ARTT: (rating) -> 2 * 4 * rating
		ARTLT: (rating) -> (5 * 4 + 2 * 2 + (6 - 2) * 2) * rating
		ARTBA: (rating) -> 2 * 4 * rating
		ARTTC: (rating) -> 1 * 4 * rating
		ARTSC: (rating) -> 2 * 4 * rating
		ARTLTC: (rating) -> 3 * 4 * rating
		BT: (rating) -> sz * movement.best * (if movement.units is 'hexes' then 1 else 2)
		CNARC: -> 0.5
		ECS: -> 0.25
		HT: (rating) -> Math.max.apply(null, rating) + if (rating[1] | 0) > 0 then 0.5 else 0
		IF: (rating) -> rating
		INARC: -> 1
		LTAG: -> 0.25
		MDS: (rating) -> rating
		MEL: -> 0.5
		MTAS: (rating) -> rating
		OVL: (rating) -> rating / 4
		RHS: -> Math.max (if specials['OVL'] then 1 else 0), (if (ov.value | 0) > 0 then 0.5 else 0.25)
		SNARC: -> 1
		TAG: -> 0.5
		TSEMP: (rating) -> Math.min 5, rating
		TSM: -> 1
	}

	blanketOffensiveModifiers = {
		BFC: -> -0.1
		DRO: -> -0.1
		SHLD: -> -0.1
		VRT: -> 0.1
	}

	defensiveSpecialAbilityFactors = {
		ABA: -> 0.5
		AMS: -> 1
		ARM: -> if (structure.value | 0) > 1 then 0.5 else 0
		BHJ: (rating) -> (rating / 2) * Math.floor((structure.value | 0) / 3) * (if special['BAR']? then 0.5 else 1)
		BRA: -> 0.75 * Math.floor((structure.value | 0) / 3) * (if special['BAR']? then 0.5 else 1)
		CR: -> 0.25
		FR: -> 0.5
		IRA: -> 0.5 * Math.floor((structure.value | 0) / 3) * (if special['BAR']? then 0.5 else 1)
		PNT: (rating) -> rating
		RAMS: -> 1.25
		RCA: -> 1 * Math.floor((structure.value | 0) / 3) * (if special['BAR']? then 0.5 else 1)
		SHLD: -> 1 * Math.floor((structure.value | 0) / 3) * (if special['BAR']? then 0.5 else 1)
	}

	forceBonuses = {
		AECM: -> 3
		BH: -> 2
		C3RS: -> 2
		ECM: -> 2
		LECM: -> 0.5
		MHQ: (rating) -> rating
		PRB: -> 1
		LPRB: -> 1
		RCN: -> 2
		TRN: -> 2
	}





	# TODO: calculate possible roles
	# TODO: allow manual override, no PV calculations

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

	# Calculate PV everytime pips are clicked or an input field is blurred
	(inputField.addEventListener('click', doCalculations, false)) for inputField in [
		card
		structurePipContainer
		armorPipContainer
	]
	(inputField.addEventListener('blur', doCalculations, false)) for inputField in [
		unit
		variant
		pv
		tp
		sz
		tmm
		mv
		role
		skill
		short
		medium
		long
		ov
		structure
		armor
		special
	]
