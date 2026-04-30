Class {
	#name : 'CPProcessDesignTailoringPolicy',
	#superclass : 'CFLabelledObject',
	#instVars : [
		'comment'
	],
	#category : 'BVC-BPM-Core',
	#package : 'BVC-BPM-Core'
}

{ #category : 'accessing' }
CPProcessDesignTailoringPolicy >> comment [
	^ comment
]

{ #category : 'accessing' }
CPProcessDesignTailoringPolicy >> comment: anObject [
	comment := anObject
]

{ #category : 'descriptions' }
CPProcessDesignTailoringPolicy >> commentDescription [
	<magritteDescription>
	^ MAMemoDescription new
		accessor: #comment;
		label: 'Comment';
		priority: 100;
		cfCategory: #general;
		yourself
]

