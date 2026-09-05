"I identify one staged BPMN flow-element container inside a Process editing transaction.

I carry the semantic container, the Foundation memento that owns its flowElements relation, and that exact Magritte relation description. Root Process and nested CPSubProcess containers therefore use the same explicit editing contract."
Class {
	#name : 'CPProcessFlowContainerContext',
	#superclass : 'Object',
	#instVars : [
		'container',
		'memento',
		'flowElementsDescription'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPProcessFlowContainerContext class >> container: aContainer memento: aMemento flowElementsDescription: aDescription [
	^ self new
		container: aContainer;
		memento: aMemento;
		flowElementsDescription: aDescription;
		yourself
]

{ #category : 'instance creation' }
CPProcessFlowContainerContext class >> rootFor: aProcessMemento [
	| description |
	description := aProcessMemento magritteDescription
		detect: [ :each | each handlesSelector: #flowElements ].
	^ self
		container: aProcessMemento model
		memento: aProcessMemento
		flowElementsDescription: description
]

{ #category : 'resolving' }
CPProcessFlowContainerContext class >> forContainer: aContainer inRootMemento: aProcessMemento [
	^ (self rootFor: aProcessMemento)
		contextForContainer: aContainer
]

{ #category : 'resolving' }
CPProcessFlowContainerContext class >> containingFlowElement: aFlowElement inRootMemento: aProcessMemento [
	^ (self rootFor: aProcessMemento)
		contextContainingFlowElement: aFlowElement
]

{ #category : 'resolving' }
CPProcessFlowContainerContext >> contextForContainer: aContainer [
	| nested |
	container == aContainer ifTrue: [ ^ self ].
	self stagedFlowElements do: [ :each |
		each isSubProcess ifTrue: [
			nested := (self childContextForSubProcess: each)
				contextForContainer: aContainer.
			nested ifNotNil: [ ^ nested ] ] ].
	^ nil
]

{ #category : 'resolving' }
CPProcessFlowContainerContext >> contextContainingFlowElement: aFlowElement [
	| nested |
	(self stagedFlowElements identityIncludes: aFlowElement) ifTrue: [ ^ self ].
	self stagedFlowElements do: [ :each |
		each isSubProcess ifTrue: [
			nested := (self childContextForSubProcess: each)
				contextContainingFlowElement: aFlowElement.
			nested ifNotNil: [ ^ nested ] ] ].
	^ nil
]

{ #category : 'resolving' }
CPProcessFlowContainerContext >> childContextForSubProcess: aSubProcess [
	| childMemento childDescription |
	childMemento := memento
		childMementoFor: aSubProcess
		inRelation: flowElementsDescription.
	childDescription := childMemento magritteDescription
		detect: [ :each | each handlesSelector: #flowElements ].
	^ self class
		container: aSubProcess
		memento: childMemento
		flowElementsDescription: childDescription
]

{ #category : 'staged state' }
CPProcessFlowContainerContext >> stagedFlowElements [
	^ memento readUsing: flowElementsDescription
]

{ #category : 'staged state' }
CPProcessFlowContainerContext >> childMementoFor: aFlowElement [
	^ memento
		childMementoFor: aFlowElement
		inRelation: flowElementsDescription
]

{ #category : 'staged state' }
CPProcessFlowContainerContext >> writeFlowElements: aCollection [
	memento write: aCollection using: flowElementsDescription
]

{ #category : 'staged state' }
CPProcessFlowContainerContext >> detachChildMementoFor: aFlowElement [
	memento
		detachChildMementoFor: aFlowElement
		inRelation: flowElementsDescription
]

{ #category : 'accessing' }
CPProcessFlowContainerContext >> container [ ^ container ]

{ #category : 'accessing' }
CPProcessFlowContainerContext >> container: anObject [ container := anObject ]

{ #category : 'accessing' }
CPProcessFlowContainerContext >> memento [ ^ memento ]

{ #category : 'accessing' }
CPProcessFlowContainerContext >> memento: anObject [ memento := anObject ]

{ #category : 'accessing' }
CPProcessFlowContainerContext >> flowElementsDescription [ ^ flowElementsDescription ]

{ #category : 'accessing' }
CPProcessFlowContainerContext >> flowElementsDescription: aDescription [ flowElementsDescription := aDescription ]
