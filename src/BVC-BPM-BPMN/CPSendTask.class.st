Class {
	#name : 'CPSendTask',
	#superclass : 'CPTask',
	#instVars : [ 'messageRef', 'operationRef', 'implementation' ],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'task type' }
CPSendTask class >> taskTypeLabel [ ^ 'Send' ]
{ #category : 'task type' }
CPSendTask class >> taskTypeIcon [ ^ #arrowUpFromSquare ]
{ #category : 'defaults' }
CPSendTask class >> defaultIcon [ ^ self taskTypeIcon ]
{ #category : 'initialization' }
CPSendTask >> initialize [ super initialize. implementation := '##WebService' ]
{ #category : 'accessing' }
CPSendTask >> messageRef [ ^ messageRef ]
{ #category : 'accessing' }
CPSendTask >> messageRef: aMessage [ messageRef := aMessage ]
{ #category : 'accessing' }
CPSendTask >> operationRef [ ^ operationRef ]
{ #category : 'accessing' }
CPSendTask >> operationRef: anOperation [ operationRef := anOperation ]
{ #category : 'accessing' }
CPSendTask >> implementation [ ^ implementation ]
{ #category : 'accessing' }
CPSendTask >> implementation: aString [ implementation := aString ]
{ #category : 'descriptions' }
CPSendTask >> messageRefDescription [ <magritteDescription> ^ MAToOneRelationDescription new accessor: #messageRef; classes: { CPMessage }; reference: CPMessage new labelDescription; label: 'Message'; priority: 100; group: 'Relations'; yourself ]
{ #category : 'descriptions' }
CPSendTask >> operationRefDescription [ <magritteDescription> ^ MAToOneRelationDescription new accessor: #operationRef; classes: { CPOperation }; reference: CPOperation new labelDescription; label: 'Operation'; priority: 110; group: 'Relations'; yourself ]
{ #category : 'descriptions' }
CPSendTask >> implementationDescription [ <magritteDescription> ^ MAStringDescription new accessor: #implementation; label: 'Implementation'; priority: 120; group: 'Execution'; beRequired; yourself ]
