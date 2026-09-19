"I bind one CallableElement data input and output to a BPMN Operation."
Class {
	#name : 'CPInputOutputBinding',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'inputDataRef',
		'outputDataRef',
		'operationRef'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'accessing' }
CPInputOutputBinding >> inputDataRef [ ^ inputDataRef ]
{ #category : 'accessing' }
CPInputOutputBinding >> inputDataRef: aDataInput [ inputDataRef := aDataInput ]
{ #category : 'accessing' }
CPInputOutputBinding >> outputDataRef [ ^ outputDataRef ]
{ #category : 'accessing' }
CPInputOutputBinding >> outputDataRef: aDataOutput [ outputDataRef := aDataOutput ]
{ #category : 'accessing' }
CPInputOutputBinding >> operationRef [ ^ operationRef ]
{ #category : 'accessing' }
CPInputOutputBinding >> operationRef: anOperation [ operationRef := anOperation ]

{ #category : 'descriptions' }
CPInputOutputBinding >> inputDataRefDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new accessor: #inputDataRef; classes: { CPDataInput }; reference: CPDataInput new labelDescription; label: 'Input data'; priority: 100; group: 'Binding'; beRequired; yourself
]
{ #category : 'descriptions' }
CPInputOutputBinding >> outputDataRefDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new accessor: #outputDataRef; classes: { CPDataOutput }; reference: CPDataOutput new labelDescription; label: 'Output data'; priority: 110; group: 'Binding'; beRequired; yourself
]
{ #category : 'descriptions' }
CPInputOutputBinding >> operationRefDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new accessor: #operationRef; classes: { CPOperation }; reference: CPOperation new labelDescription; label: 'Operation'; priority: 120; group: 'Binding'; beRequired; yourself
]
