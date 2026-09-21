Class { #name : 'CPSignalEventDefinition', #superclass : 'CPEventDefinition', #instVars : [ 'signalRef' ], #category : 'BVC-BPM-BPMN', #package : 'BVC-BPM-BPMN' }
{ #category : 'event type' }
CPSignalEventDefinition class >> eventTypeLabel [ ^ 'Signal' ]
{ #category : 'event type' }
CPSignalEventDefinition class >> eventTypeIcon [ ^ #towerReceive ]
{ #category : 'accessing' }
CPSignalEventDefinition >> signalRef [ ^ signalRef ]
{ #category : 'accessing' }
CPSignalEventDefinition >> signalRef: aSignal [ signalRef := aSignal ]
{ #category : 'descriptions' }
CPSignalEventDefinition >> signalRefDescription [ <magritteDescription> ^ MAToOneRelationDescription new accessor: #signalRef; classes: { CPSignal }; reference: CPSignal new labelDescription; label: 'Signal'; priority: 100; group: 'Relations'; yourself ]


{ #category : 'execution semantics' }
CPSignalEventDefinition >> resultDefinition [
	^ signalRef
]

{ #category : 'testing' }
CPSignalEventDefinition >> isSignalEventDefinition [ ^ true ]
