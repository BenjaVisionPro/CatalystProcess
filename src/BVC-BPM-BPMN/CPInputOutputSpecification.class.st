Class {
	#name : 'CPInputOutputSpecification',
	#superclass : 'CFIdentifiableObject',
	#instVars : [ 'dataInputs', 'dataOutputs', 'inputSets', 'outputSets' ],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'initialization' }
CPInputOutputSpecification >> initialize [
	super initialize.
	dataInputs := OrderedCollection new.
	dataOutputs := OrderedCollection new.
	inputSets := OrderedCollection with: CPInputSet new.
	outputSets := OrderedCollection with: CPOutputSet new
]
{ #category : 'accessing' }
CPInputOutputSpecification >> dataInputs [ ^ dataInputs ]
{ #category : 'accessing' }
CPInputOutputSpecification >> dataInputs: aCollection [ dataInputs := aCollection asOrderedCollection ]
{ #category : 'accessing' }
CPInputOutputSpecification >> dataOutputs [ ^ dataOutputs ]
{ #category : 'accessing' }
CPInputOutputSpecification >> dataOutputs: aCollection [ dataOutputs := aCollection asOrderedCollection ]
{ #category : 'accessing' }
CPInputOutputSpecification >> inputSets [ ^ inputSets ]
{ #category : 'accessing' }
CPInputOutputSpecification >> inputSets: aCollection [ inputSets := aCollection asOrderedCollection ]
{ #category : 'accessing' }
CPInputOutputSpecification >> outputSets [ ^ outputSets ]
{ #category : 'accessing' }
CPInputOutputSpecification >> outputSets: aCollection [ outputSets := aCollection asOrderedCollection ]

{ #category : 'descriptions' }
CPInputOutputSpecification >> dataInputsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new accessor: #dataInputs; classes: { CPDataInput }; reference: CPDataInput new labelDescription; label: 'Data inputs'; priority: 100; group: 'Data'; beOrdered; yourself
]
{ #category : 'descriptions' }
CPInputOutputSpecification >> dataOutputsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new accessor: #dataOutputs; classes: { CPDataOutput }; reference: CPDataOutput new labelDescription; label: 'Data outputs'; priority: 110; group: 'Data'; beOrdered; yourself
]
{ #category : 'descriptions' }
CPInputOutputSpecification >> inputSetsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new accessor: #inputSets; classes: { CPInputSet }; reference: CPInputSet new labelDescription; label: 'Input sets'; priority: 120; group: 'Data'; beOrdered; yourself
]
{ #category : 'descriptions' }
CPInputOutputSpecification >> outputSetsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new accessor: #outputSets; classes: { CPOutputSet }; reference: CPOutputSet new labelDescription; label: 'Output sets'; priority: 130; group: 'Data'; beOrdered; yourself
]
