Class {
	#name : 'CPDiagramElement',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'modelElement'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'accessing' }
CPDiagramElement >> modelElement [
	^ modelElement
]

{ #category : 'accessing' }
CPDiagramElement >> modelElement: anObject [
	modelElement := anObject
]
