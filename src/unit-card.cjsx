React = require('react/addons')

###
Ability class constructor takes in an identifier and possibly value(s)
Finds the correct Abilities object returns the properly initialized class
###
class AbilityFactory
	constructor:
		link to parent here and encapsulate the abilities
	create: (parentCard, abilityName, abilityValues...) ->
		ability = do ->
			return new Obj() for id, Obj in Abilities when id is name
		unless ability?
			return new Ability parentCard, abilityName, abilityValues
		
		class Ability 
			constructor: (parentCard, abilityName, abilityValues...) ->
				@parent = parentCard
				@name = abilityName.toUpperCase()
				@values = abilityValues
				@parse = new RegExp('^' + name + '$', 'i')
				@stringify = -> @name
			
			get: -> @value

		class SpecialAbility extends Ability
			@get: -> @name + @value


		Abilities: {
			ART: {	# Artillery Weapon
				parse: /^ART(\w+)-(\d)/
				stringify: -> @name + @values[0] + '-' + @values[1]
				offensiveSpecialAbilityFactor: (match) ->
					# Lookup artillary weapon type's damage
					# return innerDamage * 4 + outerDamage * 2 + Math.max(0, (radius - 2 / 2) * 2)
					10 # Placeholder for now
			},
			BT: {	# Booby Trap
				stringify: -> @name + @values[0]
				offensiveSpecialAbilityFactor: ->
					@parent.size * @parent.getFastestMove() / 2
			},
			C3BSM: {
				parse: /^C3BSM(\d+)$/
				offensiveblanketMultiplier: -> 0.1
			},
			C3BSS: {
				parse: /^C3BSS(\d+)$/
				offensiveblanketMultiplier: -> 0.1
			},
			C3I: {
				parse: /^C3I(\d+)$/
				offensiveblanketMultiplier: -> 0.1
			},
			C3M: {
				parse: /^C3M(\d+)$/
				offensiveblanketMultiplier: -> 0.1
			},
			C3MM: {
				parse: /^C3MM(\d+)$/
				offensiveblanketMultiplier: -> 0.1
			},
			C3S: {
				parse: /^C3S(\d+)$/
				offensiveblanketMultiplier: -> 0.1
			},
			CNARC: {	# Compact Narc Missile Beacon
				offensiveSpecialAbilityFactor: -> 0.5
			},
			ECS: {	# RISC Emergency Coolant Sys.
				offensiveSpecialAbilityFactor: -> 0.25
			},
			HT: {	# Heat
				parse: /^HT(\d+)(?:\/)?(\d+)?(?:\/)?(\d+)?$/
				offensiveSpecialAbilityFactor: (match) ->
					match[1] + (if match[2]? then 0.5 else 0)
			},
			IF: {	# Indirect-Fire
				parse: /^IF(\d+)$/
				offensiveSpecialAbilityFactor: (match) -> match[1]
			},
			INARC: {	# Improved Narc Missile Beacon
				parse: /^INARC$/
				offensiveSpecialAbilityFactor: -> 1
			},
			MDS: {	# Mine Dispensers
				parse: /^MDS(\d+)$/
				offensiveSpecialAbilityFactor: (match) ->
					match[1]
			},
			MEL: {	# Melee Weapon
				offensiveSpecialAbilityFactor: -> 0.5
			},
			MTAS: {	# Taser (BattleMech)
				parse: /^MTAS(\d+)$/
				offensiveSpecialAbilityFactor: (match) ->
					match[1]
			},
			OVL: {	# Overheat Long
				offensiveSpecialAbilityFactor: ->
					@abilities.overheatValue * 0.25
			},
			RHS: {	# Radical Heat Sink System
				offensiveSpecialAbilityFactor: ->
					if @abilities.OV?
						return 1
					if @abilities.overheatValue is gt 0
						return 0.5
					0.25
			},
			SNARC: {	# Standard Narc Missile Beacon
				offensiveSpecialAbilityFactor: -> 1
			},
			TAG: {	# TAG (Standard)
				offensiveSpecialAbilityFactor: -> 0.5
			},
			TSEMP: {	# Tight Stream EMP Weapon
				parse: /^TSEMP\d+$/ 
				offensiveSpecialAbilityFactor: (match) ->
					Math.min match[1], 5
			},
			TSM: {	# Triple-Strength Moymer
				offensiveSpecialAbilityFactor: -> 1
			},
			VRT: {
				offensiveblanketMultiplier: -> 0.1
			}
		}




class UnitCard extends React.Component

	constructor: (props) ->
		console.log 'UnitCard'
		@state =
			uniqueId: Math.random().toString(36).substr(2)
			name: props.name || ''
			variant: props.variant || ''
			type: props.type || ''
			size: props.size || 1
			tmm: props.tmm || [0]
			move: props.move || {
				'': 0	# Standard Ground
			}
			role: props.role || ''
			skill: props.skill || 4
			overheatValue: props.overheatValue || 0
			damage: props.damage || {
				'': { # Standard weapons fire arc
					short: 0
					medium: 0
					long: 0
					extreme: 0
					special: []
				}
			}
			armor: props.armor || 0
			structure: props.structure || 1
			threshold: props.threshold
			special: props.special || {}
			pointValue: props.pointValue || 1
			calculatePV: props.calculatePV || new GroundUnitCalculator()


	addAbility: AbilityFactory.create


	handleEdit: (field) ->
		(event) =>
			event.preventDefault()
			newVal = {}
			newVal[field] = event.target.value
			@setState newVal

	render: ->
		<div>
			<br>
			<label htmlFor={@state.uniqueId + 'name'}></label>
			<input 
				id={@state.uniqueId + 'name'}
				placeholder="Name" 
				value={@state.name}
				onChange={@handleEdit 'name'}
				type="text"
			/>

			<br>
			<label htmlFor={@state.uniqueId + 'variant'}></label>
			<input 
				id={@state.uniqueId + 'variant'}
				placeholder="Variant" 
				value={@state.variant}
				onChange={@handleEdit 'variant'}
				type="text"
			/>
			
			<br>
			<label htmlFor={@state.uniqueId + 'type'}>TP</label>
			<input 
				id={@state.uniqueId + 'type'}
				placeholder="type" 
				value={@state.type}
				onChange={@handleEdit 'type'}
				type="text"
			/>
			
			<br>
			<label htmlFor={@state.uniqueId + 'size'}>SZ</label>
			<input 
				id={@state.uniqueId + 'size'}
				placeholder="size" 
				value={@state.size}
				onChange={@handleEdit 'size'}
				type="text"
			/>
			
			<br>
			<label htmlFor={@state.uniqueId + 'tmm'}>TMM</label>
			<input 
				id={@state.uniqueId + 'tmm'}
				placeholder="tmm" 
				value={@state.tmm}
				type="text"
			/>
			
			<br>
			<label htmlFor={@state.uniqueId + 'move'}>MV</label>
			<input 
				id={@state.uniqueId + 'move'}
				placeholder="move" 
				value={@state.move}
				onChange={@handleEdit 'move'}
				type="text"
			/>
			
			<br>
			<label htmlFor={@state.uniqueId + 'role'}>Role</label>
			<input 
				id={@state.uniqueId + 'role'}
				placeholder="role" 
				value={@state.role}
				onChange={@handleEdit 'role'}
				type="text"
			/>
			
			<br>
			<label htmlFor={@state.uniqueId + 'Skill'}>Skill</label>
			<input 
				id={@state.uniqueId + 'Skill'}
				placeholder="Skill" 
				value={@state.Skill}
				onChange={@handleEdit 'Skill'}
				type="text"
			/>
			
			<br>
			<label htmlFor={@state.uniqueId + 'overheatValue'}>OV</label>
			<input 
				id={@state.uniqueId + 'overheatValue'}
				placeholder="overheatValue" 
				value={@state.overheatValue}
				onChange={@handleEdit 'overheatValue'}
				type="text"
			/>
			
			<br>
			<label htmlFor={@state.uniqueId + 'armor'}>A</label>
			<input 
				id={@state.uniqueId + 'armor'}
				placeholder="armor" 
				value={@state.armor}
				onChange={@handleEdit 'armor'}
				type="text"
			/>
			
			<br>
			<label htmlFor={@state.uniqueId + 'structure'}>S</label>
			<input 
				id={@state.uniqueId + 'structure'}
				placeholder="structure" 
				value={@state.structure}
				onChange={@handleEdit 'structure'}
				type="text"
			/>
			
			<br>
			<label htmlFor={@state.uniqueId + 'threshold'}>TH</label>
			<input 
				id={@state.uniqueId + 'threshold'}
				placeholder="threshold" 
				value={@state.threshold}
				onChange={@handleEdit 'threshold'}
				type="text"
			/>
			
			<br>
			<label htmlFor={@state.uniqueId + 'special'}>Special</label>
			<input 
				id={@state.uniqueId + 'special'}
				placeholder="special" 
				value={@state.special}
				onChange={@handleEdit 'special'}
				type="text"
			/>
			
			<br>
			<label htmlFor={@state.uniqueId + 'pv'}>PV</label>
			<input 
				id={@state.uniqueId + 'pv'}
				placeholder="pv" 
				value={@state.pv}
				type="text"
			/>
			
		</div>



class GroundUnit extends UnitCard

	calculatePV: ->
		offensiveValue = offensiveValue()

	offensiveValue: ->
		offensiveFactor = @attackDamageFactor() + @unitSizeFactor() + @overheatFactor() + @offensiveSpecialAbilityFactor()
		offensiveValue = offensiveFactor * @blanketOffensiveModifier()
		Math.round(offensiveValue * 2, 1) / 2 # Round to nearest 0.5

	attackDamageFactor: ->
		@short + 2 * @medium + @long
	unitSizeFactor: ->
		sz = 0
		if @type is 'BM' or @type is 'PM'
			sz = @size / 2
		return sz
	overheatFactor: ->
		ov = (if @overheatValue > 0 then 1 else 0) +
			(if @overheatValue > 1 then (@overheatValue - 1) / 2 else 0)
		
		shortRangeOnly = @short > 0 and @medium + @long is 0
		if shortRangeOnly
			ov = ov / 2
		return ov
	offensiveSpecialAbilityFactor: ->
		specialAbilityFactor = 0
		specialAbilityFactor += ability.offensiveSpecialAbilityFactor?()|0 for ability in @abilities
		return specialAbilityFactor
	blanketOffensiveModifier: ->
		blanketMultiplier = 1
		blanketMultiplier += ability.offensiveblanketMultiplier?()|0 for ability in @abilities
		return blanketMultiplier
		

	getFastestMove: ->
		speeds = for movement, speed of @move
		speeds.sort()
		speeds[0]


class BattleMech extends GroundUnit
	constructor: ->
		super

module.exports = UnitCard