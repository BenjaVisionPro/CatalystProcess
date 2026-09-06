"I provide scrollable workspace around one Process or Collaboration diagram.

BrScrollPane remains the sole scrolling/panning interaction owner. I add presentation-only space before and after the diagram so native trackpad/mouse-wheel scrolling can position the diagram comfortably in the viewport. I install no mouse, drag, wheel or gesture handlers and I never alter BPMN DI coordinates."
Class {
	#name : 'CPDiagramScrollContentElement',
	#superclass : 'BlElement',
	#instVars : [
		'diagramElement',
		'diagramExtent',
		'workspaceMargin',
		'workspaceExtent'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'initialization' }
CPDiagramScrollContentElement >> initialize [
	super initialize.
	diagramExtent := 640 @ 260.
	workspaceMargin := 320 @ 220.
	workspaceExtent := diagramExtent + (workspaceMargin * 2).
	self
		layout: BlFrameLayout new;
		background: Color transparent;
		clipChildren: false
]

{ #category : 'hosting' }
CPDiagramScrollContentElement >> diagramElement: anElement extent: anExtent [
	diagramElement ifNotNil: [ diagramElement removeFromParent ].
	diagramElement := anElement.
	diagramExtent := anExtent.
	self updateWorkspaceExtent.
	diagramElement
		constraintsDo: [ :c | c ignoreByLayout ];
		extent: diagramExtent;
		relocate: workspaceMargin.
	self addChild: diagramElement
]

{ #category : 'hosting' }
CPDiagramScrollContentElement >> diagramExtent: anExtent [
	diagramExtent := anExtent.
	diagramElement ifNotNil: [
		diagramElement extent: diagramExtent ].
	self updateWorkspaceExtent
]

{ #category : 'private - layout' }
CPDiagramScrollContentElement >> updateWorkspaceExtent [
	workspaceExtent := diagramExtent + (workspaceMargin * 2).
	self constraintsDo: [ :c |
		c horizontal exact: workspaceExtent x.
		c vertical exact: workspaceExtent y ]
]

{ #category : 'accessing - testing' }
CPDiagramScrollContentElement >> diagramElement [
	^ diagramElement
]

{ #category : 'accessing - testing' }
CPDiagramScrollContentElement >> diagramExtent [
	^ diagramExtent
]

{ #category : 'accessing - testing' }
CPDiagramScrollContentElement >> workspaceMargin [
	^ workspaceMargin
]


{ #category : 'accessing - testing' }
CPDiagramScrollContentElement >> workspaceExtent [
	^ workspaceExtent
]
