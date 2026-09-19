"I represent the content of a BPMN communication between Participants."
Class {
	#name : 'CPMessage',
	#superclass : 'CFLabelledObject',
	#instVars : [ 'itemRef' ],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'accessing' }
CPMessage >> itemRef [ ^ itemRef ]
{ #category : 'accessing' }
CPMessage >> itemRef: anItemDefinition [ itemRef := anItemDefinition ]
{ #category : 'descriptions' }
CPMessage >> itemRefDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new accessor: #itemRef; classes: { CPItemDefinition }; reference: CPItemDefinition new identifierDescription; label: 'Item definition'; priority: 100; group: 'Data'; yourself
]
{ #category : 'accessing - presentation' }
CPMessage class >> defaultIcon [ ^ #envelope ]
