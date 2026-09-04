Class {
	#name : 'CPTaskTypeSelection',
	#superclass : 'Object',
	#instVars : [
		'taskClass'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPTaskTypeSelection class >> taskClass: aTaskClass [
	^ self new
		taskClass: aTaskClass;
		yourself
]

{ #category : 'accessing' }
CPTaskTypeSelection >> taskClass [
	^ taskClass
]

{ #category : 'accessing' }
CPTaskTypeSelection >> taskClass: aTaskClass [
	taskClass := aTaskClass
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
