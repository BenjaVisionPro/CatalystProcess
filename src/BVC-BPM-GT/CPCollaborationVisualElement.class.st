"I render the definitional Collaboration of one root CPProcess.

The enclosing Atelier transaction remains rooted at that CPProcess. I read the Process's definitionalCollaborationRef and its Collaboration DI, render each Participant as a CPParticipantShapeElement, and host the already-configured root CPProcessVisualElement inside the Participant whose processRef is the edited Process.

Black-box Participants render as Pools without Process content. Participant editing and MessageFlow rendering are separate subsequent capabilities."
Class {
	#name : 'CPCollaborationVisualElement',
	#superclass : 'BlElement',
	#instVars : [
		'processMemento',
		'processVisual',
		'collaboration',
		'collaborationMemento',
		'diagramMemento',
		'elementsDescription',
		'participantElementsByParticipant'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'initialization' }
CPCollaborationVisualElement >> initialize [
	super initialize.
	participantElementsByParticipant := IdentityDictionary new.
	self
		layout: BlFrameLayout new;
		clipChildren: false
]

{ #category : 'configuration' }
CPCollaborationVisualElement >> processMemento: aMemento processVisual: aProcessVisual [
	processMemento := aMemento.
	processVisual := aProcessVisual.
	self refresh
]

{ #category : 'updating' }
CPCollaborationVisualElement >> refresh [
	| collaborationDescription diagramDescription diagram elements participantShapes contentExtent |
	self removeChildren.
	participantElementsByParticipant removeAll.

	collaborationDescription := processMemento magritteDescription
		detect: [ :each | each handlesSelector: #definitionalCollaborationRef ].
	collaboration := processMemento readUsing: collaborationDescription.
	collaboration ifNil: [ ^ self ].
	collaborationMemento := processMemento
		childMementoFor: collaboration
		inRelation: collaborationDescription.

	diagramDescription := collaborationMemento magritteDescription
		detect: [ :each | each handlesSelector: #diagram ].
	diagram := collaborationMemento readUsing: diagramDescription.
	diagram ifNil: [ ^ self ].
	diagramMemento := collaborationMemento
		childMementoFor: diagram
		inRelation: diagramDescription.
	elementsDescription := diagramMemento magritteDescription
		detect: [ :each | each handlesSelector: #elements ].
	elements := diagramMemento readUsing: elementsDescription.
	participantShapes := elements select: [ :each |
		| modelElement |
		each isShape and: [
			modelElement := self stagedModelElementOf: each.
			modelElement notNil and: [ modelElement isParticipant ] ] ].

	contentExtent := self canvasExtentFor: participantShapes.
	self constraintsDo: [ :c |
		c horizontal matchParent.
		c vertical matchParent.
		c minWidth: contentExtent x.
		c minHeight: contentExtent y ].
	participantShapes do: [ :each | self addParticipantShape: each ]
]

{ #category : 'private - building' }
CPCollaborationVisualElement >> addParticipantShape: aShape [
	| participant bounds element |
	participant := self stagedModelElementOf: aShape.
	bounds := self stagedBoundsOf: aShape.
	(participant isNil or: [ bounds isNil ]) ifTrue: [ ^ self ].
	element := CPParticipantShapeElement new
		participant: participant
		shape: aShape
		bounds: bounds
		background: self poolBackgroundColor
		borderColor: self poolBorderColor.
	element
		constraintsDo: [ :c | c ignoreByLayout ];
		relocate: bounds origin.
	participantElementsByParticipant at: participant put: element.
	self addChild: element.

	participant processRef == processMemento model ifTrue: [
		element hostProcessVisual: processVisual ]
]

{ #category : 'private - staged state' }
CPCollaborationVisualElement >> stagedBoundsOf: aShape [
	| shapeMemento description |
	shapeMemento := diagramMemento
		childMementoFor: aShape
		inRelation: elementsDescription.
	description := shapeMemento magritteDescription
		detect: [ :each | each handlesSelector: #bounds ].
	^ shapeMemento readUsing: description
]

{ #category : 'private - staged state' }
CPCollaborationVisualElement >> stagedModelElementOf: aShape [
	| shapeMemento description |
	shapeMemento := diagramMemento
		childMementoFor: aShape
		inRelation: elementsDescription.
	description := shapeMemento magritteDescription
		detect: [ :each | each handlesSelector: #modelElement ].
	^ shapeMemento readUsing: description
]

{ #category : 'private - layout' }
CPCollaborationVisualElement >> canvasExtentFor: someShapes [
	| maximumX maximumY |
	maximumX := 720.
	maximumY := 360.
	someShapes do: [ :each |
		| bounds |
		bounds := self stagedBoundsOf: each.
		bounds ifNotNil: [
			maximumX := maximumX max: bounds right + 80.
			maximumY := maximumY max: bounds bottom + 80 ] ].
	^ maximumX @ maximumY
]

{ #category : 'private - theme' }
CPCollaborationVisualElement >> poolBackgroundColor [
	^ self resolvedThemeColor: self theme surfaces baseBackground
]

{ #category : 'private - theme' }
CPCollaborationVisualElement >> poolBorderColor [
	^ self resolvedThemeColor: self theme typography primaryForeground
]

{ #category : 'private - theme' }
CPCollaborationVisualElement >> resolvedThemeColor: aThemeableColor [
	^ aThemeableColor blocResolveColorForTheme: self theme
]

{ #category : 'accessing - testing' }
CPCollaborationVisualElement >> collaboration [
	^ collaboration
]

{ #category : 'accessing - testing' }
CPCollaborationVisualElement >> processVisual [
	^ processVisual
]

{ #category : 'accessing - testing' }
CPCollaborationVisualElement >> participantElementsByParticipant [
	^ participantElementsByParticipant
]
