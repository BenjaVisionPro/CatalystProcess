"I provide the Process palette stencils using the same FontAwesome icon language as the rest of the editor. Start, Stop and Event deliberately share one circle glyph and differ only by restrained colour."
Class {
	#name : 'CPProcessPaletteIcons',
	#superclass : 'Object',
	#category : 'BVC-BPM-GT-Palette',
	#package : 'BVC-BPM-GT',
	#tag : 'Palette'
}

{ #category : 'private - icons' }
CPProcessPaletteIcons class >> fontAwesomeIcon: aSelector color: aColorBlock [
	^ [
		| icon |
		icon := FontAwesomeIcons icon: aSelector.
		icon
			height: 18;
			addAptitude: (BrLazyStyleCommonAptitude new
				default: [ :aStyle | icon color: (aColorBlock value: icon theme) ];
				yourself);
			yourself ] asStencil
]

{ #category : 'private - icons' }
CPProcessPaletteIcons class >> fontAwesomeIcon: aSelector [
	^ self fontAwesomeIcon: aSelector color: [ :aTheme | aTheme diagram iconForeground ]
]

{ #category : 'private - icons' }
CPProcessPaletteIcons class >> processIcon: aSelector [
	^ [
		| icon |
		icon := CPBpmnIcons icon: aSelector.
		icon
			height: 18;
			addAptitude: (BrLazyStyleCommonAptitude new
				default: [ :aStyle | icon color: icon theme diagram iconForeground ];
				yourself);
			yourself ] asStencil
]

{ #category : 'icons' }
CPProcessPaletteIcons class >> startEvent [
	^ self fontAwesomeIcon: #circle color: [ :aTheme | aTheme diagram startEventColor ]
]

{ #category : 'icons' }
CPProcessPaletteIcons class >> endEvent [
	^ self fontAwesomeIcon: #circle color: [ :aTheme | aTheme diagram endEventColor ]
]

{ #category : 'icons' }
CPProcessPaletteIcons class >> event [
	^ self fontAwesomeIcon: #circle
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
			yourself.
		divider := BlElement new
			extent: 1.5 @ 14;
			constraintsDo: [ :c |
				c frame horizontal alignLeft.
				c frame vertical alignCenter.
				c margin: (BlInsets top: 0 right: 0 bottom: 0 left: 5) ];
			yourself.
		element addChild: divider.
		element addAptitude: (BrLazyStyleCommonAptitude new
			default: [ :aStyle |
				element border: (BlBorder paint: (element theme diagram iconForeground blocResolveColorForTheme: element theme) width: 1.5).
				divider background: element theme diagram iconForeground ];
			yourself).
		element ] asStencil
]


{ #category : 'icons' }
CPProcessPaletteIcons class >> data [
	^ self fontAwesomeIcon: #database
]
