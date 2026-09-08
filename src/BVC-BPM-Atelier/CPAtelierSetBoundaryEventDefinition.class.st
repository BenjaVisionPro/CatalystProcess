"I stage the single EventDefinition class selected for an existing Boundary Event without replacing the Boundary Event identity."
Class {
	#name : 'CPAtelierSetBoundaryEventDefinition',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'boundaryEvent',
		'definitionClass',
		'flowContainer',
		'processMemento'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierSetBoundaryEventDefinition class >> boundaryEvent: aBoundaryEvent definitionClass: aDefinitionClass flowContainer: aFlowContainer processMemento: aMemento [
	^ self new
		boundaryEvent: aBoundaryEvent;
		definitionClass: aDefinitionClass;
		flowContainer: aFlowContainer;
		processMemento: aMemento;
		yourself
]

{ #category : 'assessing' }
CPAtelierSetBoundaryEventDefinition >> assess [
	| context eventMemento description currentDefinitions currentClass proposedDefinitions |
	boundaryEvent ifNil: [ ^ self rejectedCurrent: nil proposed: nil because: 'A Boundary Event is required.' ].
	boundaryEvent isBoundaryEvent ifFalse: [ ^ self rejectedCurrent: nil proposed: nil because: 'The edited node must be a Boundary Event.' ].
	(CPBoundaryEvent eventDefinitionTypes includes: definitionClass) ifFalse: [
		^ self rejectedCurrent: nil proposed: nil because: 'The requested EventDefinition type is not supported by Boundary Events.' ].
	context := CPProcessFlowContainerContext
		forContainer: flowContainer
		inRootMemento: processMemento.
	context ifNil: [ ^ self rejectedCurrent: nil proposed: nil because: 'The Boundary Event flow container is not staged.' ].
	(context stagedFlowElements identityIncludes: boundaryEvent) ifFalse: [
		^ self rejectedCurrent: nil proposed: nil because: 'The Boundary Event does not belong to the staged flow container.' ].
	eventMemento := context childMementoFor: boundaryEvent.
	description := eventMemento magritteDescription detect: [ :each | each handlesSelector: #eventDefinitions ].
	currentDefinitions := eventMemento readUsing: description.
	currentClass := currentDefinitions size = 1
		ifTrue: [ currentDefinitions first class ]
		ifFalse: [ nil ].
	currentClass == definitionClass ifTrue: [
		^ self rejectedCurrent: currentClass proposed: definitionClass because: 'The Boundary Event already has the requested EventDefinition type.' ].
	proposedDefinitions := OrderedCollection with: definitionClass new.
	[ description validate: proposedDefinitions ]
		on: MAValidationError
		do: [ :anException |
			^ self rejectedCurrent: currentClass proposed: definitionClass because: anException printString ].
	^ CPAtelierSetBoundaryEventDefinitionAssessment
		boundaryEvent: boundaryEvent
		currentDefinitionClass: currentClass
		proposedDefinitionClass: definitionClass
]

{ #category : 'applying' }
CPAtelierSetBoundaryEventDefinition >> applyAssessment: anAssessment [
	| context eventMemento description |
	context := CPProcessFlowContainerContext
		forContainer: flowContainer
		inRootMemento: processMemento.
	eventMemento := context childMementoFor: boundaryEvent.
	description := eventMemento magritteDescription detect: [ :each | each handlesSelector: #eventDefinitions ].
	eventMemento
		write: (OrderedCollection with: anAssessment proposedDefinitionClass new)
		using: description
]

{ #category : 'private' }
CPAtelierSetBoundaryEventDefinition >> rejectedCurrent: currentClass proposed: proposedClass because: aString [
	^ CPAtelierSetBoundaryEventDefinitionAssessment
		boundaryEvent: boundaryEvent
		currentDefinitionClass: currentClass
		proposedDefinitionClass: proposedClass
		rejectedBecause: aString
]

{ #category : 'accessing' }
CPAtelierSetBoundaryEventDefinition >> boundaryEvent: anObject [ boundaryEvent := anObject ]
{ #category : 'accessing' }
CPAtelierSetBoundaryEventDefinition >> definitionClass: aClass [ definitionClass := aClass ]
{ #category : 'accessing' }
CPAtelierSetBoundaryEventDefinition >> flowContainer: anObject [ flowContainer := anObject ]
{ #category : 'accessing' }
CPAtelierSetBoundaryEventDefinition >> processMemento: anObject [ processMemento := anObject ]
