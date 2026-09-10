"I represent the Diagram Common Font value used by a CPLabelStyle."
Class {
	#name : 'CPFont',
	#superclass : 'Object',
	#instVars : [
		'name',
		'size',
		'isBold',
		'isItalic',
		'isUnderline',
		'isStrikeThrough'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'accessing' }
CPFont >> name [ ^ name ]
{ #category : 'accessing' }
CPFont >> name: aString [ name := aString ]
{ #category : 'accessing' }
CPFont >> size [ ^ size ]
{ #category : 'accessing' }
CPFont >> size: aNumber [ size := aNumber ]
{ #category : 'accessing' }
CPFont >> isBold [ ^ isBold ]
{ #category : 'accessing' }
CPFont >> isBold: aBoolean [ isBold := aBoolean ]
{ #category : 'accessing' }
CPFont >> isItalic [ ^ isItalic ]
{ #category : 'accessing' }
CPFont >> isItalic: aBoolean [ isItalic := aBoolean ]
{ #category : 'accessing' }
CPFont >> isUnderline [ ^ isUnderline ]
{ #category : 'accessing' }
CPFont >> isUnderline: aBoolean [ isUnderline := aBoolean ]
{ #category : 'accessing' }
CPFont >> isStrikeThrough [ ^ isStrikeThrough ]
{ #category : 'accessing' }
CPFont >> isStrikeThrough: aBoolean [ isStrikeThrough := aBoolean ]

{ #category : 'descriptions' }
CPFont >> nameDescription [
	<magritteDescription>
	^ MAStringDescription new accessor: #name; label: 'Name'; priority: 100; yourself
]
{ #category : 'descriptions' }
CPFont >> sizeDescription [
	<magritteDescription>
	^ MANumberDescription new accessor: #size; label: 'Size'; priority: 110; yourself
]
{ #category : 'descriptions' }
CPFont >> isBoldDescription [
	<magritteDescription>
	^ MABooleanDescription new accessor: #isBold; label: 'Bold'; priority: 120; yourself
]
{ #category : 'descriptions' }
CPFont >> isItalicDescription [
	<magritteDescription>
	^ MABooleanDescription new accessor: #isItalic; label: 'Italic'; priority: 130; yourself
]
{ #category : 'descriptions' }
CPFont >> isUnderlineDescription [
	<magritteDescription>
	^ MABooleanDescription new accessor: #isUnderline; label: 'Underline'; priority: 140; yourself
]
{ #category : 'descriptions' }
CPFont >> isStrikeThroughDescription [
	<magritteDescription>
	^ MABooleanDescription new accessor: #isStrikeThrough; label: 'Strike through'; priority: 150; yourself
]
