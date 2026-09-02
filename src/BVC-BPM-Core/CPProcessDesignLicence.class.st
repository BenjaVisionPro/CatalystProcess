Class {
	#name : 'CPProcessDesignLicence',
	#superclass : 'CFLabelledObject',
	#instVars : [
		'comment'
	],
	#category : 'BVC-BPM-Core',
	#package : 'BVC-BPM-Core'
}

{ #category : 'accessing' }
CPProcessDesignLicence >> comment [
	^ comment
]

{ #category : 'accessing' }
CPProcessDesignLicence >> comment: anObject [
	comment := anObject
]

{ #category : 'descriptions' }
CPProcessDesignLicence >> commentDescription [
	<magritteDescription>
	^ MAMemoDescription new
		accessor: #comment;
		label: 'Comment';
		priority: 100;
		group: 'General';
		yourself
]

