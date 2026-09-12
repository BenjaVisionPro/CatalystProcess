"I build the Process palette's BPMN-shaped creation icons. I am presentation-only; palette items retain their provider/materialisation semantics and Process drop targets retain placement semantics."
Class {
	#name : 'CPProcessPaletteIcons',
	#superclass : 'Object',
	#category : 'BVC-BPM-GT-Palette',
	#package : 'BVC-BPM-GT',
	#tag : 'Palette'
}

{ #category : 'icons' }
CPProcessPaletteIcons class >> startEvent [
	^ [ self eventElementWithBorderColor: Color green borderWidth: 2 ] asStencil
]

{ #category : 'icons' }
CPProcessPaletteIcons class >> endEvent [
	^ [ self eventElementWithBorderColor: Color red borderWidth: 2 ] asStencil
]

{ #category : 'icons' }
CPProcessPaletteIcons class >> event [
	^ [ self eventElementWithBorderColor: Color black borderWidth: 2 ] asStencil
]

{ #category : 'private - icons' }
CPProcessPaletteIcons class >> eventElementWithBorderColor: aColor borderWidth: aWidth [
	^ BlElement new
		extent: 24 @ 24;
		geometry: BlCircleGeometry new;
		background: Color transparent;
		border: (BlBorder paint: aColor width: aWidth);
		yourself
]

{ #category : 'icons' }
CPProcessPaletteIcons class >> activity [
	^ [ BlElement new
		extent: 30 @ 22;
		geometry: (BlRoundedRectangleGeometry cornerRadius: 6);
		background: Color transparent;
		border: (BlBorder paint: Color black width: 2);
		yourself ] asStencil
]

{ #category : 'icons' }
CPProcessPaletteIcons class >> gateway [
	^ [ BlElement new
		extent: 24 @ 24;
		geometry: (BlPolygonGeometry vertices: {
			12 @ 0.
			24 @ 12.
			12 @ 24.
			0 @ 12 });
		background: Color transparent;
		border: (BlBorder paint: Color black width: 2);
		yourself ] asStencil
]

{ #category : 'icons' }
CPProcessPaletteIcons class >> subProcess [
	^ [
		| element firstDot secondDot |
		element := BlElement new
			extent: 30 @ 22;
			layout: BlFrameLayout new;
			geometry: (BlRoundedRectangleGeometry cornerRadius: 6);
			background: Color transparent;
			border: (BlBorder paint: Color black width: 2);
			yourself.
		firstDot := BlElement new
			extent: 3 @ 3;
			geometry: BlCircleGeometry new;
			background: Color black;
			constraintsDo: [ :c |
				c frame horizontal alignCenter.
				c frame vertical alignBottom.
				c margin: (BlInsets top: 0 right: 7 bottom: 3 left: 0) ];
			yourself.
		secondDot := BlElement new
			extent: 3 @ 3;
			geometry: BlCircleGeometry new;
			background: Color black;
			constraintsDo: [ :c |
				c frame horizontal alignCenter.
				c frame vertical alignBottom.
				c margin: (BlInsets top: 0 right: 0 bottom: 3 left: 7) ];
			yourself.
		element addChild: firstDot; addChild: secondDot.
		element ] asStencil
]

{ #category : 'icons' }
CPProcessPaletteIcons class >> callActivity [
	^ [ BlElement new
		extent: 30 @ 22;
		geometry: (BlRoundedRectangleGeometry cornerRadius: 6);
		background: Color transparent;
		border: (BlBorder paint: Color black width: 4);
		yourself ] asStencil
]

{ #category : 'icons' }
CPProcessPaletteIcons class >> poolLane [
	^ [
		| element divider |
		element := BlElement new
			extent: 34 @ 22;
		layout: BlFrameLayout new;
		geometry: (BlRoundedRectangleGeometry cornerRadius: 6);
		background: Color transparent;
		border: (BlBorder paint: Color black width: 2);
		yourself.
		divider := BlElement new
			extent: 2 @ 20;
			background: Color black;
			constraintsDo: [ :c |
				c frame horizontal alignLeft.
				c frame vertical alignCenter.
				c margin: (BlInsets top: 0 right: 0 bottom: 0 left: 8) ];
			yourself.
		element addChild: divider.
		element ] asStencil
]
