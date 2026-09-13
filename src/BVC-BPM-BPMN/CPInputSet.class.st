Class {
	#name : 'CPInputSet',
	#superclass : 'CFLabelledObject',
	#instVars : [ 'dataInputRefs', 'optionalInputRefs', 'whileExecutingInputRefs', 'outputSetRefs' ],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'initialization' }
CPInputSet >> initialize [
	super initialize.
	dataInputRefs := OrderedCollection new.
	optionalInputRefs := OrderedCollection new.
	whileExecutingInputRefs := OrderedCollection new.
	outputSetRefs := OrderedCollection new
]
{ #category : 'accessing' }
CPInputSet >> dataInputRefs [ ^ dataInputRefs ]
{ #category : 'accessing' }
CPInputSet >> dataInputRefs: aCollection [ dataInputRefs := aCollection asOrderedCollection ]
{ #category : 'accessing' }
CPInputSet >> optionalInputRefs [ ^ optionalInputRefs ]
{ #category : 'accessing' }
CPInputSet >> optionalInputRefs: aCollection [ optionalInputRefs := aCollection asOrderedCollection ]
{ #category : 'accessing' }
CPInputSet >> whileExecutingInputRefs [ ^ whileExecutingInputRefs ]
{ #category : 'accessing' }
CPInputSet >> whileExecutingInputRefs: aCollection [ whileExecutingInputRefs := aCollection asOrderedCollection ]
{ #category : 'accessing' }
CPInputSet >> outputSetRefs [ ^ outputSetRefs ]
{ #category : 'accessing' }
CPInputSet >> outputSetRefs: aCollection [ outputSetRefs := aCollection asOrderedCollection ]

{ #category : 'descriptions' }
CPInputSet >> dataInputRefsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new accessor: #dataInputRefs; classes: { CPDataInput }; reference: CPDataInput new labelDescription; label: 'Inputs'; priority: 100; group: 'Relations'; beOrdered; yourself
]
