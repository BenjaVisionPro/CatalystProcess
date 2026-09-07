"I hold the explicit diagram selection for one Process editor as an ordered collection of BPMN-DI identities.

I deliberately know nothing about BPMN semantics, visual elements, mementos or editing operations. Selection order is interaction order and identity is authoritative."
Class {
	#name : 'CPDiagramSelection',
	#superclass : 'Object',
	#instVars : [
		'diagramElements'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'initialization' }
CPDiagramSelection >> initialize [
	super initialize.
	diagramElements := OrderedCollection new
]

{ #category : 'accessing' }
CPDiagramSelection >> diagramElements [
	^ diagramElements copy
]

{ #category : 'testing' }
CPDiagramSelection >> includes: aDiagramElement [
	^ diagramElements identityIncludes: aDiagramElement
]

{ #category : 'testing' }
CPDiagramSelection >> isEmpty [
	^ diagramElements isEmpty
]

{ #category : 'accessing' }
CPDiagramSelection >> size [
	^ diagramElements size
]

{ #category : 'accessing' }
CPDiagramSelection >> soleDiagramElement [
	^ diagramElements size = 1
		ifTrue: [ diagramElements first ]
		ifFalse: [ nil ]
]

{ #category : 'editing' }
CPDiagramSelection >> clear [
	diagramElements removeAll
]

{ #category : 'editing' }
CPDiagramSelection >> selectOnly: aDiagramElement [
	diagramElements removeAll.
	diagramElements add: aDiagramElement
]

{ #category : 'editing' }
CPDiagramSelection >> add: aDiagramElement [
	(self includes: aDiagramElement) ifFalse: [
		diagramElements add: aDiagramElement ]
]

{ #category : 'editing' }
CPDiagramSelection >> addAll: someDiagramElements [
	someDiagramElements do: [ :each | self add: each ]
]

{ #category : 'editing' }
CPDiagramSelection >> remove: aDiagramElement [
	diagramElements remove: aDiagramElement ifAbsent: [ ]
]

{ #category : 'editing' }
CPDiagramSelection >> toggle: aDiagramElement [
	(self includes: aDiagramElement)
		ifTrue: [ self remove: aDiagramElement ]
		ifFalse: [ self add: aDiagramElement ]
]

{ #category : 'editing' }
CPDiagramSelection >> replaceWith: someDiagramElements [
	diagramElements removeAll.
	self addAll: someDiagramElements
]
