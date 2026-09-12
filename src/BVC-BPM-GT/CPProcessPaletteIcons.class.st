"I provide the Process palette stencils using the same FontAwesome icon language as the rest of the editor. Start, Stop and Event deliberately share one circle glyph and differ only by restrained colour."
Class {
	#name : 'CPProcessPaletteIcons',
	#superclass : 'Object',
	#category : 'BVC-BPM-GT-Palette',
	#package : 'BVC-BPM-GT',
	#tag : 'Palette'
}

{ #category : 'private - icons' }
CPProcessPaletteIcons class >> darkStartColor [
	^ Color r: 0.05 g: 0.16 b: 0.07
]

{ #category : 'private - icons' }
CPProcessPaletteIcons class >> darkStopColor [
	^ Color r: 0.19 g: 0.035 b: 0.035
]

{ #category : 'private - icons' }
CPProcessPaletteIcons class >> fontAwesomeIcon: aSelector color: aColor [
	^ [
		(FontAwesomeIcons icon: aSelector)
			height: 18;
			color: aColor;
			yourself ] asStencil
]

{ #category : 'private - icons' }
CPProcessPaletteIcons class >> fontAwesomeIcon: aSelector [
	^ self fontAwesomeIcon: aSelector color: Color black
]

{ #category : 'private - icons' }
CPProcessPaletteIcons class >> processIcon: aSelector [
	^ [
		(CPBpmnIcons icon: aSelector)
			height: 18;
			color: Color black;
			yourself ] asStencil
]

{ #category : 'icons' }
CPProcessPaletteIcons class >> startEvent [
	^ self fontAwesomeIcon: #circle color: self darkStartColor
]

{ #category : 'icons' }
CPProcessPaletteIcons class >> endEvent [
	^ self fontAwesomeIcon: #circle color: self darkStopColor
]

{ #category : 'icons' }
CPProcessPaletteIcons class >> event [
	^ self fontAwesomeIcon: #circle color: Color black
]

{ #category : 'icons' }
CPProcessPaletteIcons class >> activity [
	^ self fontAwesomeIcon: #rectangle
]

{ #category : 'icons' }
CPProcessPaletteIcons class >> gateway [
	^ self fontAwesomeIcon: #diamond
]

{ #category : 'icons' }
CPProcessPaletteIcons class >> subProcess [
	^ self processIcon: #subProcess
]

{ #category : 'icons' }
CPProcessPaletteIcons class >> callActivity [
	^ self processIcon: #callActivity
]

{ #category : 'icons' }
CPProcessPaletteIcons class >> poolLane [
	^ [
		| element divider |
		element := BlElement new
			extent: 22 @ 16;
			layout: BlFrameLayout new;
			geometry: (BlRoundedRectangleGeometry cornerRadius: 3);
			background: Color transparent;
			border: (BlBorder paint: Color black width: 1.5);
			yourself.
		divider := BlElement new
			extent: 1.5 @ 14;
			background: Color black;
			constraintsDo: [ :c |
				c frame horizontal alignLeft.
				c frame vertical alignCenter.
				c margin: (BlInsets top: 0 right: 0 bottom: 0 left: 5) ];
			yourself.
		element addChild: divider.
		element ] asStencil
]
