Class {
	#name : 'CPServiceTask',
	#superclass : 'CPTask',
	#instVars : [ 'implementation', 'operationRef' ],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'task type' }
CPServiceTask class >> taskTypeLabel [
	^ 'Service'
]

{ #category : 'task type' }
CPServiceTask class >> taskTypeIcon [
	^ #gear
]

{ #category : 'defaults' }
CPServiceTask class >> defaultIcon [
	^ self taskTypeIcon
]


{ #category : 'initialization' }
CPServiceTask >> initialize [
	super initialize.
	implementation := '##WebService'
]
{ #category : 'accessing' }
CPServiceTask >> implementation [ ^ implementation ]
{ #category : 'accessing' }
CPServiceTask >> implementation: aString [ implementation := aString ]
{ #category : 'accessing' }
CPServiceTask >> operationRef [ ^ operationRef ]
{ #category : 'accessing' }
CPServiceTask >> operationRef: anOperation [ operationRef := anOperation ]
{ #category : 'descriptions' }
CPServiceTask >> implementationDescription [ <magritteDescription> ^ MAStringDescription new accessor: #implementation; label: 'Implementation'; priority: 100; group: 'Execution'; beRequired; yourself ]
{ #category : 'descriptions' }
CPServiceTask >> operationRefDescription [ <magritteDescription> ^ MAToOneRelationDescription new accessor: #operationRef; classes: { CPOperation }; reference: CPOperation new labelDescription; label: 'Operation'; priority: 110; group: 'Relations'; yourself ]
