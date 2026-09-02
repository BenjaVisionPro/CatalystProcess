Class {
	#name : 'CPUser',
	#superclass : 'CFLabelledObject',
	#instVars : [
		'comment',
		'memberships'
	],
	#category : 'BVC-BPM-Core',
	#package : 'BVC-BPM-Core'
}

{ #category : 'accessing' }
CPUser >> comment [
	^ comment
]

{ #category : 'accessing' }
CPUser >> comment: anObject [
	comment := anObject
]

{ #category : 'accessing' }
CPUser >> memberships [
	^ memberships
]

{ #category : 'accessing' }
CPUser >> memberships: anObject [
	memberships := anObject
]

{ #category : 'initialization' }
CPUser >> initialize [
	super initialize.
	memberships := OrderedCollection new
]

{ #category : 'descriptions' }
CPUser >> commentDescription [
	<magritteDescription>
	^ MAMemoDescription new
		accessor: #comment;
		label: 'Comment';
		priority: 100;
		group: 'General';
		yourself
]

{ #category : 'descriptions' }
CPUser >> membershipsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #memberships;
		label: 'Memberships';
		priority: 110;
		group: 'Relations';
		yourself
]

