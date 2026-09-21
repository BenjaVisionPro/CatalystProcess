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
CPStartEvent >> matchesInstantiationOccurrence: anOccurrence [
	^ false
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
