Class {
	#name : 'CPProcessDiagramExamples',
	#superclass : 'Object',
	#category : 'BVC-BPM-GT-Examples',
	#package : 'BVC-BPM-GT',
	#tag : 'Examples'
}

{ #category : 'examples - diagram' }
CPProcessDiagramExamples >> processPresentationIncludesDiagramAndDetailForm [
	<gtExample>
	| process start task finish firstEdge secondEdge memento presentation element |
	process := CPProcessDesign new label: 'Diagram pressure test'; yourself.
	start := CPStartEventDesignNode new label: 'Start'; position: 60 @ 170; yourself.
	task := CPUserTaskDesignNode new label: 'Review'; position: 250 @ 164; yourself.
	finish := CPEndEventDesignNode new label: 'Done'; position: 470 @ 170; yourself.
	firstEdge := CPProcessDesignEdge new sourceNode: start; targetNode: task; yourself.
	secondEdge := CPProcessDesignEdge new sourceNode: task; targetNode: finish; yourself.
	process
		nodes: (OrderedCollection with: start with: task with: finish);
		edges: (OrderedCollection with: firstEdge with: secondEdge).
	memento := CFMaMemento model: process.
	presentation := CPProcessDesignPresentation new.
	presentation
		memento: memento;
		fieldContainerDo: [ :aContainer | element := aContainer ].
	self assert: presentation class equals: CPProcessDesignPresentation.
	^ (CFMaViewModel forObject: process memento: memento) asElement
]
