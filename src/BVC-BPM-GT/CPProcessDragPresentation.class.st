"I own the transient root-level presentation used while dragging one Process shape.

The real CPProcessShapeElement remains in its original CPProcessVisualElement for the entire gesture, so edge anchors and Bloc descendant invariants remain valid. I hide that real presentation and display an inert duplicate at root-diagram level. The real element continues to move inside its source visual; I mirror the same drag delta onto the root proxy. At the end of the gesture I remove the proxy and reveal the real presentation again."
Class {
	#name : 'CPProcessDragPresentation',
	#superclass : 'Object',
	#instVars : [
		'sourceElement',
		'sourceLabel',
		'proxyElement',
		'proxyLabel',
		'dragShapePosition',
		'dragLabelPosition'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPProcessDragPresentation class >> sourceElement: aSourceElement proxyElement: aProxyElement proxyLabel: aProxyLabel [
	^ self new
		sourceElement: aSourceElement;
		proxyElement: aProxyElement;
		proxyLabel: aProxyLabel;
		yourself
]

{ #category : 'dragging' }
CPProcessDragPresentation >> beginIn: aRootVisual shapeAt: aRootShapePosition labelAt: aRootLabelPosition [
	dragShapePosition := aRootShapePosition.
	dragLabelPosition := aRootLabelPosition.
	sourceLabel := sourceElement externalLabelHost.

	sourceElement visibility: BlVisibility hidden.
	sourceLabel ifNotNil: [ sourceLabel visibility: BlVisibility hidden ].

	proxyElement
		constraintsDo: [ :c | c ignoreByLayout ];
		relocate: dragShapePosition;
		preventMeAndChildrenMouseEvents.
	aRootVisual addChild: proxyElement.

	proxyLabel ifNotNil: [
		proxyLabel
			constraintsDo: [ :c | c ignoreByLayout ];
			relocate: dragLabelPosition;
			preventMeAndChildrenMouseEvents.
		aRootVisual addChild: proxyLabel ].
	^ self
]

{ #category : 'dragging' }
CPProcessDragPresentation >> moveBy: aDelta [
	proxyElement relocate: dragShapePosition + aDelta.
	proxyLabel ifNotNil: [
		proxyLabel relocate: dragLabelPosition + aDelta ]
]

{ #category : 'dragging' }
CPProcessDragPresentation >> finish [
	proxyElement removeFromParent.
	proxyLabel ifNotNil: [ proxyLabel removeFromParent ].
	sourceElement visibility: BlVisibility visible.
	sourceLabel ifNotNil: [ sourceLabel visibility: BlVisibility visible ]
]

{ #category : 'accessing' }
CPProcessDragPresentation >> sourceElement [
	^ sourceElement
]

{ #category : 'accessing' }
CPProcessDragPresentation >> sourceElement: anElement [
	sourceElement := anElement
]

{ #category : 'accessing' }
CPProcessDragPresentation >> proxyElement [
	^ proxyElement
]

{ #category : 'accessing' }
CPProcessDragPresentation >> proxyElement: anElement [
	proxyElement := anElement
]

{ #category : 'accessing' }
CPProcessDragPresentation >> proxyLabel [
	^ proxyLabel
]

{ #category : 'accessing' }
CPProcessDragPresentation >> proxyLabel: anElement [
	proxyLabel := anElement
]

{ #category : 'accessing' }
CPProcessDragPresentation >> dragShapePosition [
	^ dragShapePosition
]

{ #category : 'accessing' }
CPProcessDragPresentation >> dragLabelPosition [
	^ dragLabelPosition
]
