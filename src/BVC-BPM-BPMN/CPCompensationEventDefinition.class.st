Class { #name : 'CPCompensationEventDefinition', #superclass : 'CPEventDefinition', #instVars : [ 'activityRef', 'waitForCompletion' ], #category : 'BVC-BPM-BPMN', #package : 'BVC-BPM-BPMN' }
{ #category : 'initialization' }
CPCompensationEventDefinition >> initialize [ super initialize. waitForCompletion := true ]
{ #category : 'event type' }
CPCompensationEventDefinition class >> eventTypeLabel [ ^ 'Compensation' ]
{ #category : 'event type' }
CPCompensationEventDefinition class >> eventTypeIcon [ ^ #rotateLeft ]
{ #category : 'accessing' }
CPCompensationEventDefinition >> activityRef [ ^ activityRef ]
{ #category : 'accessing' }
CPCompensationEventDefinition >> activityRef: anActivity [ activityRef := anActivity ]
{ #category : 'accessing' }
CPCompensationEventDefinition >> waitForCompletion [ ^ waitForCompletion ]
{ #category : 'accessing' }
CPCompensationEventDefinition >> waitForCompletion: aBoolean [ waitForCompletion := aBoolean ]
{ #category : 'descriptions' }
CPCompensationEventDefinition >> activityRefDescription [ <magritteDescription> ^ MAToOneRelationDescription new accessor: #activityRef; classes: { CPActivity }; reference: CPActivity new labelDescription; label: 'Activity'; priority: 100; group: 'Relations'; yourself ]
{ #category : 'descriptions' }
CPCompensationEventDefinition >> waitForCompletionDescription [ <magritteDescription> ^ MABooleanDescription new accessor: #waitForCompletion; label: 'Wait for completion'; priority: 110; group: 'Compensation'; yourself ]
