"I am the Foundation Magritte presentation used for CPProcessDesign.

I remain a CFMaDetailPresentation and therefore retain the normal Foundation form. I add the Process diagram as another part of that presentation rather than making Atelier choose or render Process UI."
Class {
	#name : 'CPProcessDesignPresentation',
	#superclass : 'CFMaDetailPresentation',
	#instVars : [
		'positionNodeOperationBlock',
		'createNodeOperationBlock'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'private - building' }
CPProcessDesignPresentation >> prepareHostElement [
	| diagram |
	super prepareHostElement.
	diagram := CPProcessDiagramElement new
		createNodeOperationFor: createNodeOperationBlock;
		positionNodeOperationFor: positionNodeOperationBlock;
		memento: self memento.
	diagram margin: (BlInsets bottom: 10).
	self hostElement addChild: diagram
]


{ #category : 'configuration' }
CPProcessDesignPresentation >> positionNodeOperationFor: aBlock [
	positionNodeOperationBlock := aBlock
]


{ #category : 'configuration' }
CPProcessDesignPresentation >> createNodeOperationFor: aBlock [
	createNodeOperationBlock := aBlock
]
