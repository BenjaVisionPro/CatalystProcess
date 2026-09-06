"I host one Process or Collaboration diagram presentation inside the Atelier viewport.

I own only viewport translation. BPMN DI coordinates remain entirely inside the hosted diagram element. Dragging empty workspace moves the hosted presentation; node movement, marquee selection, palette drops and connection gestures remain owned by the diagram itself.

When a diagram is first installed I center it after layout. Later extent changes preserve the current pan offset."
Class {
	#name : 'CPDiagramPanElement',
	#superclass : 'BlElement',
	#instVars : [
		'diagramElement',
		'diagramExtent',
		'panOffset',
		'dragStartPointer',
		'dragStartOffset',
		'centerOnNextLayout'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'initialization' }
CPDiagramPanElement >> initialize [
	super initialize.
	diagramExtent := 640 @ 260.
	panOffset := 0 @ 0.
	centerOnNextLayout := true.
	self
		layout: BlFrameLayout new;
		background: Color transparent;
		clipChildren: false;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent ].
	self installPanning
]

{ #category : 'hosting' }
CPDiagramPanElement >> diagramElement: anElement extent: anExtent [
	diagramElement ifNotNil: [ diagramElement removeFromParent ].
	diagramElement := anElement.
	diagramExtent := anExtent.
	diagramElement
		constraintsDo: [ :c | c ignoreByLayout ];
		extent: diagramExtent;
		relocate: panOffset.
	self addChild: diagramElement.
	centerOnNextLayout := true.
	self enqueueTask: (BlTaskAction new action: [
		self centerDiagramIfRequested ])
]

{ #category : 'hosting' }
CPDiagramPanElement >> diagramExtent: anExtent [
	diagramExtent := anExtent.
	diagramElement ifNotNil: [
		diagramElement extent: diagramExtent ]
]

{ #category : 'positioning' }
CPDiagramPanElement >> centerDiagram [
	| available centeredX centeredY |
	available := self extent.
	available x isZero ifTrue: [ ^ self ].
	available y isZero ifTrue: [ ^ self ].
	centeredX := (available x - diagramExtent x) / 2.
	centeredY := (available y - diagramExtent y) / 2.
	panOffset := centeredX @ centeredY.
	diagramElement ifNotNil: [ diagramElement relocate: panOffset ]
]

{ #category : 'private - positioning' }
CPDiagramPanElement >> centerDiagramIfRequested [
	centerOnNextLayout ifFalse: [ ^ self ].
	self extent = (0 @ 0) ifTrue: [
		centerOnNextLayout := false.
		panOffset := 160 @ 100.
		diagramElement ifNotNil: [ diagramElement relocate: panOffset ].
		^ self ].
	centerOnNextLayout := false.
	self centerDiagram
]

{ #category : 'interaction' }
CPDiagramPanElement >> installPanning [
	self
		addEventHandler: (BlEventHandler
			on: BlDragStartEvent
			do: [ :anEvent |
				anEvent target == self ifTrue: [
					dragStartPointer := self globalPointToLocal: anEvent position.
					dragStartOffset := panOffset.
					anEvent consumed: true ] ]);
		addEventHandler: (BlEventHandler
			on: BlDragEvent
			do: [ :anEvent |
				dragStartPointer ifNotNil: [
					panOffset := dragStartOffset
						+ (self globalPointToLocal: anEvent position)
						- dragStartPointer.
					diagramElement ifNotNil: [
						diagramElement relocate: panOffset ].
					anEvent consumed: true ] ]);
		addEventHandler: (BlEventHandler
			on: BlDragEndEvent
			do: [ :anEvent |
				dragStartPointer ifNotNil: [
					panOffset := dragStartOffset
						+ (self globalPointToLocal: anEvent position)
						- dragStartPointer.
					diagramElement ifNotNil: [
						diagramElement relocate: panOffset ].
					dragStartPointer := nil.
					dragStartOffset := nil.
					anEvent consumed: true ] ])
]

{ #category : 'accessing - testing' }
CPDiagramPanElement >> diagramElement [
	^ diagramElement
]

{ #category : 'accessing - testing' }
CPDiagramPanElement >> diagramExtent [
	^ diagramExtent
]

{ #category : 'accessing - testing' }
CPDiagramPanElement >> panOffset [
	^ panOffset
]

{ #category : 'accessing - testing' }
CPDiagramPanElement >> panOffset: aPoint [
	panOffset := aPoint.
	centerOnNextLayout := false.
	diagramElement ifNotNil: [ diagramElement relocate: panOffset ]
]
