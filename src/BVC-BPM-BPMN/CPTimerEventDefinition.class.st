Class { #name : 'CPTimerEventDefinition', #superclass : 'CPEventDefinition', #instVars : [ 'timeDate', 'timeCycle', 'timeDuration' ], #category : 'BVC-BPM-BPMN', #package : 'BVC-BPM-BPMN' }
{ #category : 'event type' }
CPTimerEventDefinition class >> eventTypeLabel [ ^ 'Timer' ]
{ #category : 'event type' }
CPTimerEventDefinition class >> eventTypeIcon [ ^ #timer ]
{ #category : 'accessing' }
CPTimerEventDefinition >> timeDate [ ^ timeDate ]
{ #category : 'accessing' }
CPTimerEventDefinition >> timeDate: anExpression [ timeDate := anExpression ]
{ #category : 'accessing' }
CPTimerEventDefinition >> timeCycle [ ^ timeCycle ]
{ #category : 'accessing' }
CPTimerEventDefinition >> timeCycle: anExpression [ timeCycle := anExpression ]
{ #category : 'accessing' }
CPTimerEventDefinition >> timeDuration [ ^ timeDuration ]
{ #category : 'accessing' }
CPTimerEventDefinition >> timeDuration: anExpression [ timeDuration := anExpression ]
{ #category : 'testing' }
CPTimerEventDefinition >> hasSingleTimerExpression [ ^ ({ timeDate. timeCycle. timeDuration } count: #notNil) <= 1 ]
{ #category : 'descriptions' }
CPTimerEventDefinition >> timeDateDescription [ <magritteDescription> ^ MAToOneRelationDescription new accessor: #timeDate; classes: { CPExpression }; reference: CPExpression new identifierDescription; label: 'Time date'; priority: 100; group: 'Timer'; yourself ]
{ #category : 'descriptions' }
CPTimerEventDefinition >> timeCycleDescription [ <magritteDescription> ^ MAToOneRelationDescription new accessor: #timeCycle; classes: { CPExpression }; reference: CPExpression new identifierDescription; label: 'Time cycle'; priority: 110; group: 'Timer'; yourself ]
{ #category : 'descriptions' }
CPTimerEventDefinition >> timeDurationDescription [ <magritteDescription> ^ MAToOneRelationDescription new accessor: #timeDuration; classes: { CPExpression }; reference: CPExpression new identifierDescription; label: 'Time duration'; priority: 120; group: 'Timer'; yourself ]
