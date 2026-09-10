"I represent a BPMNLabelStyle owned by one CPDiagram."
Class {
	#name : 'CPLabelStyle',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'font'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'accessing' }
CPLabelStyle >> font [
	^ font
]

{ #category : 'accessing' }
CPLabelStyle >> font: aFont [
	font := aFont
]

{ #category : 'descriptions' }
CPLabelStyle >> fontDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #font;
		classes: { CPFont };
		label: 'Font';
		priority: 100;
		group: 'Style';
		beRequired;
		yourself
]
