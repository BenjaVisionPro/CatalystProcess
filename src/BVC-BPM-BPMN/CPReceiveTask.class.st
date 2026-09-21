Class {
	#name : 'CPReceiveTask',
	#superclass : 'CPTask',
	#instVars : [ 'messageRef', 'operationRef', 'implementation', 'instantiate' ],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'testing' }
CPReceiveTask >> isReceiveTask [ ^ true ]

{ #category : 'task type' }
CPReceiveTask class >> taskTypeLabel [ ^ 'Receive' ]
{ #category : 'task type' }
CPReceiveTask class >> taskTypeIcon [ ^ #arrowDownToSquare ]
{ #category : 'defaults' }
CPReceiveTask class >> defaultIcon [ ^ self taskTypeIcon ]
{ #category : 'initialization' }
CPReceiveTask >> initialize [ super initialize. implementation := '##WebService'. instantiate := false ]
{ #category : 'accessing' }
CPReceiveTask >> messageRef [ ^ messageRef ]
{ #category : 'accessing' }
CPReceiveTask >> messageRef: aMessage [ messageRef := aMessage ]
{ #category : 'accessing' }
CPReceiveTask >> operationRef [ ^ operationRef ]
{ #category : 'accessing' }
CPReceiveTask >> operationRef: anOperation [ operationRef := anOperation ]
{ #category : 'accessing' }
CPReceiveTask >> implementation [ ^ implementation ]
{ #category : 'accessing' }
CPReceiveTask >> implementation: aString [ implementation := aString ]
{ #category : 'accessing' }
CPReceiveTask >> instantiate [ ^ instantiate ]
{ #category : 'accessing' }
CPReceiveTask >> instantiate: aBoolean [ instantiate := aBoolean ]
{ #category : 'descriptions' }
CPReceiveTask >> messageRefDescription [ <magritteDescription> ^ MAToOneRelationDescription new accessor: #messageRef; classes: { CPMessage }; reference: CPMessage new labelDescription; label: 'Message'; priority: 100; group: 'Relations'; yourself ]
{ #category : 'descriptions' }
CPReceiveTask >> operationRefDescription [ <magritteDescription> ^ MAToOneRelationDescription new accessor: #operationRef; classes: { CPOperation }; reference: CPOperation new labelDescription; label: 'Operation'; priority: 110; group: 'Relations'; yourself ]
{ #category : 'descriptions' }
CPReceiveTask >> implementationDescription [ <magritteDescription> ^ MAStringDescription new accessor: #implementation; label: 'Implementation'; priority: 120; group: 'Execution'; beRequired; yourself ]
{ #category : 'descriptions' }
CPReceiveTask >> instantiateDescription [ <magritteDescription> ^ MABooleanDescription new accessor: #instantiate; label: 'Instantiate process'; priority: 130; group: 'Execution'; yourself ]
