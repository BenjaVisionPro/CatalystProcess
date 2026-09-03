"I am the Foundation Magritte presentation used for CPProcessDesign.

I remain a CFMaDetailPresentation and therefore retain the normal Foundation form. I add the Process diagram as another part of that presentation rather than making Atelier choose or render Process UI."
Class {
	#name : 'CPProcessDesignPresentation',
	#superclass : 'CFMaDetailPresentation',
	#instVars : [
		'positionNodeOperationBlock',
		'createNodeOperationBlock',
		'connectNodeOperationBlock',
		'reconnectEdgeOperationBlock',
		'removeNodeOperationBlock',
		'removeEdgeOperationBlock'
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
		connectNodeOperationFor: connectNodeOperationBlock;
		reconnectEdgeOperationFor: reconnectEdgeOperationBlock;
		removeNodeOperationFor: removeNodeOperationBlock;
		removeEdgeOperationFor: removeEdgeOperationBlock;
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


{ #category : 'configuration' }
CPProcessDesignPresentation >> connectNodeOperationFor: aBlock [
	connectNodeOperationBlock := aBlock
]


{ #category : 'configuration' }
CPProcessDesignPresentation >> reconnectEdgeOperationFor: aBlock [
	reconnectEdgeOperationBlock := aBlock
]


{ #category : 'configuration' }
CPProcessDesignPresentation >> removeNodeOperationFor: aBlock [
	removeNodeOperationBlock := aBlock
]

{ #category : 'configuration' }
CPProcessDesignPresentation >> removeEdgeOperationFor: aBlock [
	removeEdgeOperationBlock := aBlock
]
