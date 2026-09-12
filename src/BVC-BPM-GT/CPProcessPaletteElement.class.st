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
		hExact: 190;
		vFitContent;
		padding: (BlInsets all: 10);
		cellSpacing: 12;
		geometry: (BlRoundedRectangleGeometry cornerRadius: 10);
		border: (BlBorder paint: Color black width: 1);
		addAptitude: CFGlassSurfaceAptitude new
]

{ #category : 'private - building' }
CPProcessPaletteElement >> newHeaderElement [
	^ BlElement new
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical exact: 16 ];
		geometry: (BlRoundedRectangleGeometry cornerRadius: 8);
		background: Color black;
		yourself
]

{ #category : 'private - building' }
CPProcessPaletteElement >> newItemsElement [
	^ BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 12;
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
	| rows |
	itemsElement ifNil: [ ^ self ].
	itemsElement removeChildren.
	palette ifNil: [ ^ self ].
	rows := paletteRows ifNil: [ { palette items } ].
	rows do: [ :aRow |
		| rowElement rowWidth leftPadding |
		rowWidth := (aRow size * 48) + (((aRow size - 1) max: 0) * 10).
		leftPadding := ((170 - rowWidth) max: 0) / 2.
		rowElement := BrHorizontalPane new
			hMatchParent;
			vExact: 44;
			cellSpacing: 10;
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
			c vertical exact: 28 ];
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
		extent: 48 @ 44;
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
