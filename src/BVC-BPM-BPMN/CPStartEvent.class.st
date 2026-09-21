Class {
	#name : 'CPStartEvent',
	#superclass : 'CPCatchEvent',
	#instVars : [
		'isInterrupting'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}



{ #category : 'initialization' }
CPStartEvent >> initialize [
	super initialize.
	isInterrupting := true
]

{ #category : 'accessing' }
CPStartEvent >> isInterrupting [
	^ isInterrupting
]

{ #category : 'accessing' }
CPStartEvent >> isInterrupting: aBoolean [
	isInterrupting := aBoolean
]

{ #category : 'descriptions' }
CPStartEvent >> isInterruptingDescription [
	<magritteDescription>
	^ MABooleanDescription new
		accessor: #isInterrupting;
		label: 'Interrupting';
		priority: 190;
		group: 'Execution';
		yourself
]
{ #category : 'testing' }
CPStartEvent >> isStartEvent [ ^ true ]


{ #category : 'defaults' }
CPStartEvent class >> defaultIcon [
	^ #startEvent
]

{ #category : 'event type' }
CPStartEvent class >> startEventTypes [
	^ { CPNoneStartEvent . CPMessageStartEvent . CPTimerStartEvent . CPSignalStartEvent . CPConditionalStartEvent . CPErrorStartEvent . CPEscalationStartEvent . CPCompensationStartEvent }
]

{ #category : 'event type' }
CPStartEvent class >> eventTypeLabel [
	^ 'None'
]

{ #category : 'event type' }
CPStartEvent class >> eventTypeIcon [
	^ #circle
]

{ #category : 'testing' }
CPStartEvent >> isStartEvent [
	^ true
]

{ #category : 'execution' }
CPStartEvent >> eventDefinitionMatchingInstantiationOccurrence: anOccurrence [
	anOccurrence ifNil: [ ^ nil ].
	self eventDefinitions do: [ :each |
		each isMessageEventDefinition ifTrue: [ each messageRef == anOccurrence definition ifTrue: [ ^ each ] ].
		each isSignalEventDefinition ifTrue: [ each signalRef == anOccurrence definition ifTrue: [ ^ each ] ].
		each isTimerEventDefinition ifTrue: [ each == anOccurrence definition ifTrue: [ ^ each ] ].
		each isConditionalEventDefinition ifTrue: [ each == anOccurrence definition ifTrue: [ ^ each ] ] ].
	^ nil
]

{ #category : 'execution' }
CPStartEvent >> matchesInstantiationOccurrence: anOccurrence [
	^ (self eventDefinitionMatchingInstantiationOccurrence: anOccurrence) notNil
]

{ #category : 'testing' }
CPStartEvent >> isMultipleStartEvent [
	^ self eventDefinitions size > 1 and: [ self parallelMultiple not ]
]

{ #category : 'testing' }
CPStartEvent >> isParallelMultipleStartEvent [
	^ self eventDefinitions size > 1 and: [ self parallelMultiple ]
]

{ #category : 'execution' }
CPStartEvent >> conditionAllowsInstantiationIn: anExecutionScope [
	^ false
]

{ #category : 'testing' }
CPStartEvent >> isErrorStartEvent [
	^ false
]

{ #category : 'testing' }
CPStartEvent >> isEscalationStartEvent [
	^ false
]

{ #category : 'testing' }
CPStartEvent >> isMessageStartEvent [
	^ false
]


{ #category : 'testing' }
CPStartEvent >> isSignalStartEvent [
	^ false
]

{ #category : 'testing' }
CPStartEvent >> isTimerStartEvent [
	^ false
]

{ #category : 'testing' }
CPStartEvent >> isConditionalStartEvent [ ^ false ]
