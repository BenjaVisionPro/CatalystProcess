Class { #name : 'CPErrorEventDefinition', #superclass : 'CPEventDefinition', #instVars : [ 'error' ], #category : 'BVC-BPM-BPMN', #package : 'BVC-BPM-BPMN' }
{ #category : 'event type' }
CPErrorEventDefinition class >> eventTypeLabel [ ^ 'Error' ]
{ #category : 'event type' }
CPErrorEventDefinition class >> eventTypeIcon [ ^ #circleExclamation ]
{ #category : 'accessing' }
CPErrorEventDefinition >> error [ ^ error ]
{ #category : 'accessing' }
CPErrorEventDefinition >> error: anError [ error := anError ]
{ #category : 'descriptions' }
CPErrorEventDefinition >> errorDescription [ <magritteDescription> ^ MAToOneRelationDescription new accessor: #error; classes: { CPError }; reference: CPError new labelDescription; label: 'Error'; priority: 100; group: 'Relations'; yourself ]

{ #category : 'execution semantics' }
CPErrorEventDefinition >> interruptsActivityWithFailure [
	^ true
]
