Class { #name : 'CPEscalationEventDefinition', #superclass : 'CPEventDefinition', #instVars : [ 'escalationRef' ], #category : 'BVC-BPM-BPMN', #package : 'BVC-BPM-BPMN' }
{ #category : 'event type' }
CPEscalationEventDefinition class >> eventTypeLabel [ ^ 'Escalation' ]
{ #category : 'event type' }
CPEscalationEventDefinition class >> eventTypeIcon [ ^ #chevronsUp ]
{ #category : 'accessing' }
CPEscalationEventDefinition >> escalationRef [ ^ escalationRef ]
{ #category : 'accessing' }
CPEscalationEventDefinition >> escalationRef: anEscalation [ escalationRef := anEscalation ]
{ #category : 'descriptions' }
CPEscalationEventDefinition >> escalationRefDescription [ <magritteDescription> ^ MAToOneRelationDescription new accessor: #escalationRef; classes: { CPEscalation }; reference: CPEscalation new labelDescription; label: 'Escalation'; priority: 100; group: 'Relations'; yourself ]


{ #category : 'execution semantics' }
CPEscalationEventDefinition >> catchesEscalation: anEscalation [
	^ escalationRef == anEscalation
]


{ #category : 'execution semantics' }
CPEscalationEventDefinition >> resultDefinition [
	^ escalationRef
]
