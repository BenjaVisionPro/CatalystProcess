"I describe the bounded native-scroll viewport for one top-level diagram plane.

Given a viewport extent and authored diagram extent, I compute the exact per-axis camera slack and native content extent. A fitting diagram can travel from edge to edge without any authored content leaving the viewport; an oversized diagram has no extra whitespace."
Class {
	#name : 'CPDiagramViewport',
	#superclass : 'Object',
	#instVars : [
		'viewportExtent',
		'diagramExtent',
		'cameraSlack',
		'canvasExtent'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPDiagramViewport class >> viewportExtent: aViewportExtent diagramExtent: aDiagramExtent [
	^ self new
		viewportExtent: aViewportExtent;
		diagramExtent: aDiagramExtent;
		recompute;
		yourself
]

{ #category : 'initialization' }
CPDiagramViewport >> initialize [
	super initialize.
	viewportExtent := 1 @ 1.
	diagramExtent := 0 @ 0.
	cameraSlack := 0 @ 0.
	canvasExtent := 1 @ 1
]

{ #category : 'private - computing' }
CPDiagramViewport >> recompute [
	cameraSlack := (viewportExtent - diagramExtent) max: 0 @ 0.
	diagramExtent = (0 @ 0)
		ifTrue: [
			cameraSlack := 0 @ 0.
			canvasExtent := viewportExtent ]
		ifFalse: [
			canvasExtent := diagramExtent + (cameraSlack * 2) ]
]

{ #category : 'accessing' }
CPDiagramViewport >> viewportExtent [
	^ viewportExtent
]

{ #category : 'accessing' }
CPDiagramViewport >> viewportExtent: anExtent [
	viewportExtent := anExtent max: 1 @ 1
]

{ #category : 'accessing' }
CPDiagramViewport >> diagramExtent [
	^ diagramExtent
]

{ #category : 'accessing' }
CPDiagramViewport >> diagramExtent: anExtent [
	diagramExtent := anExtent max: 0 @ 0
]

{ #category : 'accessing' }
CPDiagramViewport >> cameraSlack [
	^ cameraSlack
]

{ #category : 'accessing' }
CPDiagramViewport >> canvasExtent [
	^ canvasExtent
]
