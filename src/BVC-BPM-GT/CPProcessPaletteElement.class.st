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
		hExact: 98;
		vExact: 151;
		padding: (BlInsets all: 8);
		cellSpacing: 4;
		geometry: (BlRoundedRectangleGeometry cornerRadius: 8);
		border: (BlBorder paint: Color black width: 1);
		addAptitude: CFGlassSurfaceAptitude new
]

{ #category : 'private - building' }
CPProcessPaletteElement >> newHeaderElement [
	^ BlElement new
		extent: 24 @ 3;
		geometry: (BlRoundedRectangleGeometry cornerRadius: 1.5);
		background: (Color black alpha: 0.38);
		constraintsDo: [ :c |
			c linear horizontal alignCenter ];
		yourself
]

{ #category : 'private - building' }
CPProcessPaletteElement >> newItemsElement [
	^ BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 8;
		yourself
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
	| rows maximumColumns contentWidth contentHeight |
	itemsElement ifNil: [ ^ self ].
	itemsElement removeChildren.
	palette ifNil: [ ^ self ].
	rows := paletteRows ifNil: [ { palette items } ].
	maximumColumns := rows inject: 0 into: [ :maximum :aRow | maximum max: aRow size ].
	contentWidth := (maximumColumns * 22) + (((maximumColumns - 1) max: 0) * 8).
	contentHeight := (rows size * 20) + (((rows size - 1) max: 0) * 8) + 8 + 16.
	self
		hExact: contentWidth + 16;
		vExact: 3 + 4 + contentHeight + 16.
	rows do: [ :aRow |
		| rowElement rowWidth leftPadding |
		rowWidth := (aRow size * 22) + (((aRow size - 1) max: 0) * 8).
		leftPadding := ((contentWidth - rowWidth) max: 0) / 2.
		rowElement := BrHorizontalPane new
			hMatchParent;
			vExact: 20;
			cellSpacing: 8;
			padding: (BlInsets top: 0 right: 0 bottom: 0 left: leftPadding);
			yourself.
		aRow do: [ :anItem |
			rowElement addChild: (self newItemElementFor: anItem) ].
		itemsElement addChild: rowElement ].
	self addHoverHelpElement
]

{ #category : 'private - building' }
CPProcessPaletteElement >> addHoverHelpElement [
	| helpHost |
	helpHost := BlElement new
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical exact: 16 ];
		layout: BlFrameLayout new;
		yourself.
	hoverHelpElement := BrLabel new
		hFitContent;
		vFitContent;
		aptitude: BrGlamorousLabelAptitude new;
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
		extent: 22 @ 20;
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

