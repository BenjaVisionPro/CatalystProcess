Class {
	#name : 'CPGroup',
	#superclass : 'CFLabelledObject',
	#instVars : [
		'comment',
		'members'
	],
	#category : 'BVC-BPM-Core',
	#package : 'BVC-BPM-Core'
}

{ #category : 'accessing' }
CPGroup >> comment [
	^ comment
]

{ #category : 'accessing' }
CPGroup >> comment: anObject [
	comment := anObject
]

{ #category : 'accessing' }
CPGroup >> members [
	^ members
]

{ #category : 'accessing' }
CPGroup >> members: anObject [
	members := anObject
]

{ #category : 'initialization' }
CPGroup >> initialize [
	super initialize.
	members := OrderedCollection new
]

{ #category : 'descriptions' }
CPGroup >> commentDescription [
	<magritteDescription>
	^ MAMemoDescription new
		accessor: #comment;
		label: 'Comment';
		priority: 100;
		group: 'General';
		yourself
]

{ #category : 'descriptions' }
CPGroup >> membersDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #members;
		label: 'Members';
		priority: 110;
		group: 'Relations';
		yourself
]

