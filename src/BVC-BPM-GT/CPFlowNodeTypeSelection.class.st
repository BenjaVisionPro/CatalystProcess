Class {
	#name : 'CPFlowNodeTypeSelection',
	#superclass : 'Object',
	#instVars : [
		'typeClass'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPFlowNodeTypeSelection class >> typeClass: aClass [
	^ self new
		typeClass: aClass;
		yourself
]

{ #category : 'accessing' }
CPFlowNodeTypeSelection >> typeClass [
	^ typeClass
]

{ #category : 'accessing' }
CPFlowNodeTypeSelection >> typeClass: aClass [
	typeClass := aClass
]

{ #category : 'descriptions' }
CPFlowNodeTypeSelection >> typeClassDescription [
	<magritteDescription>
	^ MASingleOptionDescription new
		accessor: #typeClass;
		label: self typeDescriptionLabel;
		options: self typeClasses;
		autoAccept: true;
		fieldConfigure: [ :field |
			field bePopup
				displayBlock: [ :aClass | self typeLabelFor: aClass ] ];
		blocOptionIconStencil: [ :aClass |
			(FontAwesomeIcons defaultStyle icon: (self typeIconFor: aClass))
				size: 16 @ 16;
				yourself ];
		beRequired;
		yourself
]

{ #category : 'type protocol' }
CPFlowNodeTypeSelection >> typeClasses [
	^ self subclassResponsibility
]

{ #category : 'type protocol' }
CPFlowNodeTypeSelection >> typeDescriptionLabel [
	^ self subclassResponsibility
]

{ #category : 'type protocol' }
CPFlowNodeTypeSelection >> typeLabelFor: aClass [
	^ self subclassResponsibility
]

{ #category : 'type protocol' }
CPFlowNodeTypeSelection >> typeIconFor: aClass [
	^ self subclassResponsibility
]
