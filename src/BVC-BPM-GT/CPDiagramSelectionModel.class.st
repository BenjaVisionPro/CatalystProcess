"I own the one selection state shared by every visual that participates in a Process diagram editor."
Class {
	#name : 'CPDiagramSelectionModel',
	#superclass : 'Object',
	#instVars : [
		'modelElements',
		'selectedModelElement',
		'changeBlocks'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'initialization' }
CPDiagramSelectionModel >> initialize [
	super initialize.
	modelElements := IdentitySet new.
	selectedModelElement := nil.
	changeBlocks := OrderedCollection new
]

{ #category : 'accessing' }
CPDiagramSelectionModel >> modelElements [
	^ modelElements
]

{ #category : 'accessing' }
CPDiagramSelectionModel >> selectedModelElements [
	^ modelElements copy
]

{ #category : 'accessing' }
CPDiagramSelectionModel >> selectedModelElement [
	^ selectedModelElement
]

{ #category : 'testing' }
CPDiagramSelectionModel >> includes: aModelElement [
	^ modelElements includes: aModelElement
]

{ #category : 'changing' }
CPDiagramSelectionModel >> selectOnly: aModelElement [
	modelElements removeAll.
	aModelElement ifNotNil: [ modelElements add: aModelElement ].
	selectedModelElement := aModelElement.
	self notifyChanged
]

{ #category : 'changing' }
CPDiagramSelectionModel >> toggle: aModelElement [
	(modelElements includes: aModelElement)
		ifTrue: [ modelElements remove: aModelElement ]
		ifFalse: [ modelElements add: aModelElement ].
	selectedModelElement := (modelElements includes: aModelElement)
		ifTrue: [ aModelElement ]
		ifFalse: [
			modelElements
				ifEmpty: [ nil ]
				ifNotEmpty: [ modelElements anyOne ] ].
	self notifyChanged
]

{ #category : 'changing' }
CPDiagramSelectionModel >> selectAll: someModelElements primary: aModelElement [
	modelElements removeAll.
	modelElements addAll: someModelElements.
	selectedModelElement := aModelElement.
	self notifyChanged
]

{ #category : 'changing' }
CPDiagramSelectionModel >> clear [
	(modelElements isEmpty and: [ selectedModelElement isNil ]) ifTrue: [ ^ self ].
	modelElements removeAll.
	selectedModelElement := nil.
	self notifyChanged
]

{ #category : 'announcing' }
CPDiagramSelectionModel >> changedDo: aBlock [
	changeBlocks add: aBlock
]

{ #category : 'private - announcing' }
CPDiagramSelectionModel >> notifyChanged [
	changeBlocks do: [ :aBlock | aBlock value ]
]
