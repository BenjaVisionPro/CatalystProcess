Class { #name : 'CPConditionalEventDefinition', #superclass : 'CPEventDefinition', #instVars : [ 'condition' ], #category : 'BVC-BPM-BPMN', #package : 'BVC-BPM-BPMN' }
{ #category : 'event type' }
CPConditionalEventDefinition class >> eventTypeLabel [ ^ 'Conditional' ]
{ #category : 'event type' }
CPConditionalEventDefinition class >> eventTypeIcon [ ^ #option ]
{ #category : 'accessing' }
CPConditionalEventDefinition >> condition [ ^ condition ]
{ #category : 'accessing' }
CPConditionalEventDefinition >> condition: anExpression [ condition := anExpression ]
{ #category : 'descriptions' }
CPConditionalEventDefinition >> conditionDescription [ <magritteDescription> ^ MAToOneRelationDescription new accessor: #condition; classes: { CPExpression }; reference: CPExpression new identifierDescription; label: 'Condition'; priority: 100; group: 'Condition'; beRequired; yourself ]

{ #category : 'testing' }
CPConditionalEventDefinition >> isConditionalEventDefinition [ ^ true ]
