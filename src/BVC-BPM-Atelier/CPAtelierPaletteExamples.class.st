"I prove that Process can configure an ordinary Atelier palette without a Process-specific asset hierarchy."
Class {
	#name : 'CPAtelierPaletteExamples',
	#superclass : 'Object',
	#category : 'BVC-BPM-Atelier-Examples',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Examples'
}

{ #category : 'examples - palette' }
CPAtelierPaletteExamples >> processNodePaletteSuppliesFreshNodeTypes [
	<gtExample>
	| palette userTaskItem serviceTaskItem firstUserTask secondUserTask serviceTask |
	palette := CFAtelierPalette new.
	userTaskItem := CFAtelierPaletteItem
		label: 'User task'
		provider: (CFAtelierFactoryProvider factory: [ CPUserTaskDesignNode new ]).
	serviceTaskItem := CFAtelierPaletteItem
		label: 'Service task'
		provider: (CFAtelierFactoryProvider factory: [ CPServiceTaskDesignNode new ]).
	palette
		add: userTaskItem;
		add: serviceTaskItem.

	firstUserTask := palette items first materialize.
	secondUserTask := palette items first materialize.
	serviceTask := palette items second materialize.

	self assert: firstUserTask class equals: CPUserTaskDesignNode.
	self assert: secondUserTask class equals: CPUserTaskDesignNode.
	self assert: firstUserTask ~~ secondUserTask.
	self assert: serviceTask class equals: CPServiceTaskDesignNode.
	^ palette
]

{ #category : 'examples - palette' }
CPAtelierPaletteExamples >> paletteCandidateParticipatesInCreateNodeOperation [
	<gtExample>
	| design memento nodesDescription palette item candidate operation assessment |
	design := CPProcessDesign new.
	memento := CFMaMemento model: design.
	nodesDescription := memento magritteDescription
		detect: [ :each | each handlesSelector: #nodes ].
	palette := CFAtelierPalette new.
	item := CFAtelierPaletteItem
		label: 'User task'
		provider: (CFAtelierFactoryProvider factory: [ CPUserTaskDesignNode new ]).
	palette add: item.

	candidate := item materialize.
	operation := CPAtelierCreateNode
		node: candidate
		position: 120@80
		processMemento: memento
		nodesDescription: nodesDescription.
	assessment := operation apply.

	self assert: assessment isApplicable.
	self assert: (memento readUsing: nodesDescription) size equals: 1.
	self assert: (memento readUsing: nodesDescription) first == candidate.
	self assert: candidate position equals: 120@80.
	self assert: design nodes isEmpty.
	^ assessment
]
