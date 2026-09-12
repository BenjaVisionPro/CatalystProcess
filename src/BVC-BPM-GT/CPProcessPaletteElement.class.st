"I present the Process BPMN creation palette as an ordered grid of domain-shaped tools with one shared hover-help area. I reuse CFAtelierPaletteElement's provider materialisation, drag identity, capture and palette movement mechanics."
Class {
	#name : 'CPProcessPaletteElement',
	#superclass : 'CFAtelierPaletteElement',
	#instVars : [
		'paletteRows',
		'hoverHelpElement',
		'hoveredItem'
	],
	#category : 'BVC-BPM-GT-Palette',
	#package : 'BVC-BPM-GT',
	#tag : 'Palette'
}

{ #category : 'private - building' }
CPProcessPaletteElement >> configureAppearance [
	self
		hExact: 92;
		vExact: 140;
		padding: (BlInsets all: 5);
		cellSpacing: 0;
		geometry: (BlRoundedRectangleGeometry cornerRadius: 8);
		border: (BlBorder paint: Color black width: 1);
		effect: (BlBlurBelowEffect radius: 10);
		addAptitude: (BrLazyStyleCommonAptitude new
			default: [ :aStyle |
				aStyle background: self theme interaction subtleBackgroundTint ];
			yourself).
	self installBackgroundMoveInteraction
]

{ #category : 'private - building' }
CPProcessPaletteElement >> newHeaderElement [
	^ BlElement new
		extent: 0 @ 0;
		yourself
]

{ #category : 'private - building' }
CPProcessPaletteElement >> newItemsElement [
	^ BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 0;
		yourself
]

{ #category : 'private - interaction' }
CPProcessPaletteElement >> installBackgroundMoveInteraction [
	self when: BlMouseDownEvent do: [ :anEvent |
		(anEvent primaryButtonPressed
			and: [ (self paletteItemOwnsEventTarget: anEvent target) not ]) ifTrue: [
			draggingPalette := true.
			dragStartPointer := anEvent position.
			dragStartPosition := self position.
			anEvent consumed: true ] ]
]

{ #category : 'private - interaction' }
CPProcessPaletteElement >> paletteItemOwnsEventTarget: anElement [
	| current |
	current := anElement.
	[ current notNil and: [ current ~~ self ] ] whileTrue: [
		(current userData
			at: #atelierPaletteSource
			ifAbsent: [ false ]) ifTrue: [ ^ true ].
		current := current parent ].
	^ false
]

{ #category : 'configuration' }
CPProcessPaletteElement >> paletteRows: someRows [
	paletteRows := someRows.
	palette ifNotNil: [ self refresh ]
]

{ #category : 'accessing' }
CPProcessPaletteElement >> paletteRows [
	^ paletteRows ifNil: [ #() ]
]

{ #category : 'accessing - testing' }
CPProcessPaletteElement >> hoverHelpElement [
	^ hoverHelpElement
]

{ #category : 'updating' }
CPProcessPaletteElement >> refresh [
	| rows maximumColumns contentWidth |
	itemsElement ifNil: [ ^ self ].
	itemsElement removeChildren.
	palette ifNil: [ ^ self ].
	rows := paletteRows ifNil: [ { palette items } ].
	maximumColumns := rows inject: 0 into: [ :maximum :aRow | maximum max: aRow size ].
	contentWidth := (maximumColumns * 24) + (((maximumColumns - 1) max: 0) * 4).
	self
		hExact: contentWidth + 10;
		vExact: (rows size * 26) + 12 + 10.
	rows do: [ :aRow |
		| rowHost rowElement |
		rowHost := BlElement new
			constraintsDo: [ :c |
				c horizontal matchParent.
				c vertical exact: 26 ];
			layout: BlFrameLayout new;
			yourself.
		rowElement := BrHorizontalPane new
			hFitContent;
			vExact: 22;
			cellSpacing: 4;
			constraintsDo: [ :c |
				c frame horizontal alignCenter.
				c frame vertical alignCenter ];
			yourself.
		aRow do: [ :anItem |
			rowElement addChild: (self newItemElementFor: anItem) ].
		rowHost addChild: rowElement.
		itemsElement addChild: rowHost ].
	self addHoverHelpElement
]

{ #category : 'private - building' }
CPProcessPaletteElement >> addHoverHelpElement [
	| helpHost |
	helpHost := BlElement new
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical exact: 12 ];
		layout: BlFrameLayout new;
		yourself.
	hoverHelpElement := BrLabel new
		hFitContent;
		vFitContent;
		aptitude: (BrGlamorousLabelAptitude new
			fontSize: 9;
			yourself);
		text: '';
		constraintsDo: [ :c |
			c frame horizontal alignCenter.
			c frame vertical alignCenter ];
		yourself.
	helpHost addChild: hoverHelpElement.
	itemsElement addChild: helpHost
]

{ #category : 'private - building' }
CPProcessPaletteElement >> newItemElementFor: anItem [
	| cell iconElement |
	cell := BlElement new
		extent: 24 @ 22;
		layout: BlFrameLayout new;
		background: Color transparent;
		yourself.
	anItem icon ifNotNil: [ :anIconStencil |
		iconElement := anIconStencil asStencil asElement.
		iconElement constraintsDo: [ :c |
			c frame horizontal alignCenter.
			c frame vertical alignCenter ].
		cell addChild: iconElement ].
	cell
		addEventHandler: (BlEventHandler
			on: BlMouseEnterEvent
			do: [ :anEvent |
				hoveredItem := anItem.
				hoverHelpElement ifNotNil: [ hoverHelpElement text: anItem label ] ]);
		addEventHandler: (BlEventHandler
			on: BlMouseLeaveEvent
			do: [ :anEvent |
				hoveredItem == anItem ifTrue: [
					hoveredItem := nil.
					hoverHelpElement ifNotNil: [ hoverHelpElement text: '' ] ] ]).
	^ self configureItemElement: cell for: anItem
]
