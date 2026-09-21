Class {
	#name : 'CPConditionalStartEvent',
	#superclass : 'CPStartEvent',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}
{ #category : 'event type' }
CPConditionalStartEvent class >> eventTypeLabel [ ^ 'Conditional' ]
{ #category : 'event type' }
CPConditionalStartEvent class >> eventTypeIcon [ ^ #option ]

{ #category : 'execution' }
CPConditionalStartEvent >> conditionAllowsInstantiationIn: anExecutionScope [
	| definitions condition |
	definitions := self eventDefinitions.
	definitions size = 1 ifFalse: [ ^ false ].
	condition := definitions first condition.
	condition ifNil: [ ^ false ].
	^ anExecutionScope environment evaluateExpression: condition in: anExecutionScope
]

{ #category : 'testing' }
CPConditionalStartEvent >> isConditionalStartEvent [ ^ true ]
