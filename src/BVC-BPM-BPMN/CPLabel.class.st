"I represent a BPMNLabel owned by one CPShape or CPEdge.

My bounds are still expressed in the owning diagram's CPPlane coordinate space. I do not carry a semantic model-element reference; my meaning comes from the Shape or Edge that owns me."
Class {
	#name : 'CPLabel',
	#superclass : 'CPDiagramElement',
	#instVars : [
		'bounds',
		'labelStyle'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'accessing' }
CPLabel >> bounds [
	^ bounds
]

{ #category : 'accessing' }
CPLabel >> bounds: aRectangle [
	bounds := aRectangle
]

{ #category : 'accessing' }
CPLabel >> labelStyle [
	^ labelStyle
]

{ #category : 'accessing' }
CPLabel >> labelStyle: aLabelStyle [
	labelStyle := aLabelStyle
]

{ #category : 'descriptions' }
CPLabel >> boundsDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #bounds;
		classes: { Rectangle };
		label: 'Bounds';
		priority: 100;
		group: 'Diagram';
		yourself
]

{ #category : 'descriptions' }
CPLabel >> labelStyleDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #labelStyle;
		classes: { CPLabelStyle };
		reference: CPLabelStyle new identifierDescription;
		label: 'Label style';
		priority: 110;
		group: 'Relations';
		yourself
]
