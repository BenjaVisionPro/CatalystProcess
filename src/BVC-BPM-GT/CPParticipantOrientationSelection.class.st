"I present one Participant BPMN-DI orientation as a Foundation single-option field.

I am an inspector adapter, not BPMN semantic state. The selected value is written through CPProcessDiagramEditing so changing orientation updates the Participant and its complete Lane geometry atomically."
Class {
	#name : 'CPParticipantOrientationSelection',
	#superclass : 'Object',
	#instVars : [
		'participantShape',
		'diagramEditing',
		'isHorizontal',
		'changedBlock'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPParticipantOrientationSelection class >> shape: aShape horizontal: aBoolean diagramEditing: anEditing changedDo: aBlock [
	^ self new
		participantShape: aShape;
		diagramEditing: anEditing;
		changedBlock: aBlock;
		isHorizontalValue: aBoolean;
		yourself
]

{ #category : 'accessing' }
CPParticipantOrientationSelection >> isHorizontal [
	^ isHorizontal
]

{ #category : 'accessing' }
CPParticipantOrientationSelection >> isHorizontal: aBoolean [
	| operation assessment |
	isHorizontal = aBoolean ifTrue: [ ^ self ].
	operation := aBoolean
		ifTrue: [ diagramEditing makeParticipantHorizontal: participantShape ]
		ifFalse: [ diagramEditing makeParticipantVertical: participantShape ].
	operation ifNil: [ ^ self ].
	assessment := operation apply.
	assessment isApplicable ifFalse: [ self error: assessment rejectionMessage ].
	isHorizontal := aBoolean.
	changedBlock ifNotNil: [ changedBlock cull: aBoolean ]
]

{ #category : 'descriptions' }
CPParticipantOrientationSelection >> isHorizontalDescription [
	<magritteDescription>
	^ MASingleOptionDescription new
		accessor: #isHorizontal;
		label: 'Orientation';
		options: { false. true };
		display: [ :aBoolean |
			aBoolean ifTrue: [ 'Horizontal' ] ifFalse: [ 'Vertical' ] ];
		autoAccept: true;
		fieldConfigure: [ :field | field beGroupedButtons ];
		blocOptionIconStencil: [ :aBoolean |
			(FontAwesomeIcons defaultStyle icon: (aBoolean
				ifTrue: [ #squareHalfStrokeHorizontal ]
				ifFalse: [ #squareHalfStroke ]))
				size: 16 @ 16;
				yourself ];
		beRequired;
		yourself
]

{ #category : 'private - initialization' }
CPParticipantOrientationSelection >> isHorizontalValue: aBoolean [
	isHorizontal := aBoolean
]

{ #category : 'private - initialization' }
CPParticipantOrientationSelection >> participantShape: aShape [
	participantShape := aShape
]

{ #category : 'private - initialization' }
CPParticipantOrientationSelection >> diagramEditing: anEditing [
	diagramEditing := anEditing
]

{ #category : 'private - initialization' }
CPParticipantOrientationSelection >> changedBlock: aBlock [
	changedBlock := aBlock
]
