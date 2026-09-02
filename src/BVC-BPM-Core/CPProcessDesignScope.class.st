Class {
	#name : 'CPProcessDesignScope',
	#superclass : 'CFLabelledObject',
	#instVars : [
		'comment'
	],
	#category : 'BVC-BPM-Core',
	#package : 'BVC-BPM-Core'
}

{ #category : 'accessing' }
CPProcessDesignScope >> comment [
	^ comment
]

{ #category : 'accessing' }
CPProcessDesignScope >> comment: anObject [
	comment := anObject
]

{ #category : 'descriptions' }
CPProcessDesignScope >> commentDescription [
	<magritteDescription>
	^ MAMemoDescription new
		accessor: #comment;
		label: 'Comment';
		priority: 100;
		group: 'General';
		yourself
]

