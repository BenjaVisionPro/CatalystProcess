"I provide the Process palette stencils using the same FontAwesome and FontAwesome-style BPMN icon vocabulary as the rest of Process. Only Pool/Lane is a palette-specific composite."
Class {
	#name : 'CPProcessPaletteIcons',
	#superclass : 'Object',
	#category : 'BVC-BPM-GT-Palette',
	#package : 'BVC-BPM-GT',
	#tag : 'Palette'
}

{ #category : 'private - icons' }
CPProcessPaletteIcons class >> darkStartColor [
	^ Color r: 0.06 g: 0.20 b: 0.08
]

{ #category : 'private - icons' }
CPProcessPaletteIcons class >> darkStopColor [
	^ Color r: 0.24 g: 0.04 b: 0.04
]

{ #category : 'private - icons' }
CPProcessPaletteIcons class >> processIcon: aSelector color: aColor [
	^ [
		(CPBpmnIcons icon: aSelector)
			height: 18;
			color: aColor;
			yourself ] asStencil
]

{ #category : 'private - icons' }
CPProcessPaletteIcons class >> fontAwesomeIcon: aSelector [
	^ [
		(FontAwesomeIcons icon: aSelector)
			height: 18;
			color: Color black;
			yourself ] asStencil
]

{ #category : 'icons' }
CPProcessPaletteIcons class >> startEvent [
	^ self processIcon: #startEvent color: self darkStartColor
]

{ #category : 'icons' }
CPProcessPaletteIcons class >> endEvent [
	^ self processIcon: #endEvent color: self darkStopColor
]

{ #category : 'icons' }
CPProcessPaletteIcons class >> event [
	^ self processIcon: #intermediateEvent color: Color black
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
	^ self processIcon: #subProcess color: Color black
]

{ #category : 'icons' }
CPProcessPaletteIcons class >> callActivity [
	^ self processIcon: #callActivity color: Color black
]

{ #category : 'icons' }
CPProcessPaletteIcons class >> poolLane [
	^ [
		| element divider |
		element := BlElement new
			extent: 26 @ 16;
			layout: BlFrameLayout new;
			geometry: (BlRoundedRectangleGeometry cornerRadius: 4);
			background: Color transparent;
			border: (BlBorder paint: Color black width: 1.5);
			yourself.
		divider := BlElement new
			extent: 1.5 @ 14;
			background: Color black;
			constraintsDo: [ :c |
				c frame horizontal alignLeft.
				c frame vertical alignCenter.
				c margin: (BlInsets top: 0 right: 0 bottom: 0 left: 6) ];
			yourself.
		element addChild: divider.
		element ] asStencil
]
