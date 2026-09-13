Class {
	#name : 'CPOutputSet',
	#superclass : 'CFLabelledObject',
	#instVars : [ 'dataOutputRefs', 'optionalOutputRefs', 'whileExecutingOutputRefs', 'inputSetRefs' ],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'initialization' }
CPOutputSet >> initialize [
	super initialize.
	dataOutputRefs := OrderedCollection new.
	optionalOutputRefs := OrderedCollection new.
	whileExecutingOutputRefs := OrderedCollection new.
	inputSetRefs := OrderedCollection new
]
{ #category : 'accessing' }
CPOutputSet >> dataOutputRefs [ ^ dataOutputRefs ]
{ #category : 'accessing' }
CPOutputSet >> dataOutputRefs: aCollection [ dataOutputRefs := aCollection asOrderedCollection ]
{ #category : 'accessing' }
CPOutputSet >> optionalOutputRefs [ ^ optionalOutputRefs ]
{ #category : 'accessing' }
CPOutputSet >> optionalOutputRefs: aCollection [ optionalOutputRefs := aCollection asOrderedCollection ]
{ #category : 'accessing' }
CPOutputSet >> whileExecutingOutputRefs [ ^ whileExecutingOutputRefs ]
{ #category : 'accessing' }
CPOutputSet >> whileExecutingOutputRefs: aCollection [ whileExecutingOutputRefs := aCollection asOrderedCollection ]
{ #category : 'accessing' }
CPOutputSet >> inputSetRefs [ ^ inputSetRefs ]
{ #category : 'accessing' }
CPOutputSet >> inputSetRefs: aCollection [ inputSetRefs := aCollection asOrderedCollection ]

{ #category : 'descriptions' }
CPOutputSet >> dataOutputRefsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new accessor: #dataOutputRefs; classes: { CPDataOutput }; reference: CPDataOutput new labelDescription; label: 'Outputs'; priority: 100; group: 'Relations'; beOrdered; yourself
]
