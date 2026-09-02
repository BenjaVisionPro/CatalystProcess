Class {
	#name : 'BaselineOfCatalystProcess',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfCatalystProcess',
	#package : 'BaselineOfCatalystProcess'
}

{ #category : 'baseline' }
BaselineOfCatalystProcess >> baseline: spec [
	<baseline>
	^ spec
		for: #common
		do: [
			spec
				baseline: 'CatalystFoundation'
				with: [ spec repository: 'git@github.com:BenjaVisionPro/CatalystFoundation.git' ].
			spec
				package: 'BVC-BPM-Core'
					with: [ spec requires: #('CatalystFoundation') ];
				package: 'BVC-BPM-BPMN'
					with: [ spec requires: #('BVC-BPM-Core') ];
				package: 'BVC-BPM-Design'
					with: [ spec requires: #('BVC-BPM-Core') ];
				package: 'BVC-BPM-Definition'
					with: [ spec requires: #('BVC-BPM-Core' 'BVC-BPM-Design') ];
				package: 'BVC-BPM-Runtime'
					with: [ spec requires: #('BVC-BPM-Core' 'BVC-BPM-Definition') ];
				package: 'BVC-BPM-Automation'
					with: [ spec requires: #('BVC-BPM-Core' 'BVC-BPM-Runtime') ];
				package: 'BVC-BPM-Magritte'
					with: [ spec requires: #('BVC-BPM-Core') ];
				package: 'BVC-BPM-GT'
					with: [ spec requires: #('BVC-BPM-Core' 'BVC-BPM-Design' 'BVC-BPM-Definition' 'BVC-BPM-Runtime' 'BVC-BPM-Automation' 'BVC-BPM-Magritte') ];
				package: 'BVC-BPM-Atelier'
					with: [ spec requires: #('BVC-BPM-Design' 'BVC-Foundation-Atelier') ];
				package: 'BVC-BPM-Examples'
					with: [ spec requires: #('BVC-BPM-Core' 'BVC-BPM-Design' 'BVC-BPM-Definition' 'BVC-BPM-Runtime' 'BVC-BPM-Automation') ];
				package: 'BVC-BPM-Tests'
					with: [ spec requires: #('BVC-BPM-Examples') ].
			spec group: 'atelier' with: #('BVC-BPM-Atelier') ]
]

