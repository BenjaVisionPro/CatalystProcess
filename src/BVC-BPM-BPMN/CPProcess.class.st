Class {
	#name : 'CPProcess',
	#superclass : 'CFLabelledObject',
	#instVars : [
		'flowElements',
		'laneSets',
		'diagram',
		'definitionalCollaborationRef'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'initialization' }
CPProcess >> initialize [
	super initialize.
	flowElements := OrderedCollection new.
	laneSets := OrderedCollection new
]

{ #category : 'accessing' }
CPProcess >> flowElements [
	^ flowElements
]

{ #category : 'accessing' }
CPProcess >> flowElements: aCollection [
	| proposed |
	proposed := aCollection asOrderedCollection copy.
	flowElements copy do: [ :each |
		(proposed identityIncludes: each) ifFalse: [ self removeFlowElement: each ] ].
	proposed do: [ :each | self addFlowElement: each ].
	flowElements := proposed
]

{ #category : 'adding' }
CPProcess >> addFlowElement: aFlowElement [
	(flowElements includes: aFlowElement) ifFalse: [
		flowElements add: aFlowElement.
		aFlowElement container: self ]
]

{ #category : 'removing' }
CPProcess >> removeFlowElement: aFlowElement [
	(flowElements identityIncludes: aFlowElement) ifFalse: [ ^ self ].
	"A committed transfer has already given this element another owner.
	Remove stale source membership without disconnecting the transferred topology."
	aFlowElement container == self ifTrue: [
		aFlowElement prepareForRemovalFrom: self.
		aFlowElement container: nil ].
	flowElements remove: aFlowElement ifAbsent: [ ]
]

{ #category : 'accessing' }
CPProcess >> laneSets [
	^ laneSets
]

{ #category : 'accessing' }
CPProcess >> laneSets: aCollection [
	laneSets copy do: [ :each | self removeLaneSet: each ].
	aCollection do: [ :each | self addLaneSet: each ]
]

{ #category : 'adding' }
CPProcess >> addLaneSet: aLaneSet [
	(laneSets identityIncludes: aLaneSet) ifTrue: [ ^ self ].
	laneSets add: aLaneSet.
	aLaneSet process: self
]

{ #category : 'removing' }
CPProcess >> removeLaneSet: aLaneSet [
	(laneSets identityIncludes: aLaneSet) ifFalse: [ ^ self ].
	laneSets remove: aLaneSet.
	aLaneSet process == self ifTrue: [ aLaneSet process: nil ]
]

{ #category : 'accessing' }
CPProcess >> diagram [
	^ diagram
]

{ #category : 'accessing' }
CPProcess >> diagram: aDiagram [
	diagram := aDiagram.
	diagram ifNotNil: [ :aProcessDiagram | aProcessDiagram modelElement: self ]
]

{ #category : 'descriptions' }
CPProcess >> flowElementsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #flowElements;
		classes: { CPFlowElement };
		reference: self labelDescription;
		label: 'Flow elements';
		priority: 100;
		group: 'Relations';
		yourself
]

{ #category : 'descriptions' }
CPProcess >> laneSetsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #laneSets;
		classes: { CPLaneSet };
		reference: CPLaneSet new labelDescription;
		label: 'Lane sets';
		priority: 105;
		group: 'Relations';
		yourself
]

{ #category : 'descriptions' }
CPProcess >> diagramDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #diagram;
		classes: { CPDiagram };
		label: 'Diagram';
		priority: 110;
		group: 'Diagram';
		yourself
]


{ #category : 'accessing' }
CPProcess >> definitionalCollaborationRef [
	^ definitionalCollaborationRef
]

{ #category : 'accessing' }
CPProcess >> definitionalCollaborationRef: aCollaboration [
	definitionalCollaborationRef := aCollaboration
]

{ #category : 'descriptions' }
CPProcess >> definitionalCollaborationRefDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #definitionalCollaborationRef;
		classes: { CPCollaboration };
		reference: CPCollaboration new labelDescription;
		label: 'Definitional collaboration';
		priority: 120;
		group: 'Relations';
		yourself
]

{ #category : 'validation' }
CPProcess >> validationResult [
	^ CPProcessValidator new validateProcess: self
]


{ #category : 'testing' }
CPProcess >> isSubProcess [
	^ false
]
