Class {
	#name : 'CPTaskTypeSelection',
	#superclass : 'Object',
	#instVars : [
		'taskClass',
		'changeBlock'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPTaskTypeSelection class >> taskClass: aTaskClass changedDo: aBlock [
	^ self new
		taskClass: aTaskClass;
		changeBlock: aBlock;
		yourself
]

{ #category : 'accessing' }
CPTaskTypeSelection >> taskClass [
	^ taskClass
]

{ #category : 'accessing' }
CPTaskTypeSelection >> taskClass: aTaskClass [
	taskClass == aTaskClass ifTrue: [ ^ self ].
	taskClass := aTaskClass.
	changeBlock ifNotNil: [ :aBlock | aBlock value: aTaskClass ]
]

{ #category : 'accessing' }
CPTaskTypeSelection >> changeBlock: aBlock [
	changeBlock := aBlock
]

{ #category : 'descriptions' }
CPTaskTypeSelection >> taskClassDescription [
	<magritteDescription>
	^ MASingleOptionDescription new
		accessor: #taskClass;
		label: 'Task type';
		options: CPTask taskTypes;
		autoAccept: true;
		fieldConfigure: [ :field |
			field bePopup
				beIconOnly;
				displayBlock: [ :aTaskClass | aTaskClass taskTypeLabel ] ];
		blocOptionIconStencil: [ :aTaskClass |
			(FontAwesomeIcons defaultStyle icon: aTaskClass taskTypeIcon)
				size: 16 @ 16;
				yourself ];
		beRequired;
		yourself
]
