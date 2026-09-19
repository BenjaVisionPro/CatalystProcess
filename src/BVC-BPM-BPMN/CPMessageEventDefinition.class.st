Class {
	#name : 'CPMessageEventDefinition',
	#superclass : 'CPEventDefinition',
	#instVars : [ 'messageRef', 'operationRef' ],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}
{ #category : 'event type' }
CPMessageEventDefinition class >> eventTypeLabel [ ^ 'Message' ]
{ #category : 'event type' }
CPMessageEventDefinition class >> eventTypeIcon [ ^ #messageArrowDown ]
{ #category : 'accessing' }
CPMessageEventDefinition >> messageRef [ ^ messageRef ]
{ #category : 'accessing' }
CPMessageEventDefinition >> messageRef: aMessage [ messageRef := aMessage ]
{ #category : 'accessing' }
CPMessageEventDefinition >> operationRef [ ^ operationRef ]
{ #category : 'accessing' }
CPMessageEventDefinition >> operationRef: anOperation [ operationRef := anOperation ]
{ #category : 'descriptions' }
CPMessageEventDefinition >> messageRefDescription [ <magritteDescription> ^ MAToOneRelationDescription new accessor: #messageRef; classes: { CPMessage }; reference: CPMessage new labelDescription; label: 'Message'; priority: 100; group: 'Relations'; yourself ]
{ #category : 'descriptions' }
CPMessageEventDefinition >> operationRefDescription [ <magritteDescription> ^ MAToOneRelationDescription new accessor: #operationRef; classes: { CPOperation }; reference: CPOperation new labelDescription; label: 'Operation'; priority: 110; group: 'Relations'; yourself ]
