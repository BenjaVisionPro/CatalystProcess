Class {
	#name : 'CPProcessDesignNode',
	#superclass : 'CFLabelledObject',
	#instVars : [
		'comment',
		'position',
		'metadata'
	],
	#category : 'BVC-BPM-Design',
	#package : 'BVC-BPM-Design'
}

{ #category : 'accessing' }
CPProcessDesignNode >> comment [
	^ comment
]

{ #category : 'accessing' }
CPProcessDesignNode >> comment: anObject [
	comment := anObject
]

{ #category : 'accessing' }
CPProcessDesignNode >> position [
	^ position
]

{ #category : 'accessing' }
CPProcessDesignNode >> position: anObject [
	position := anObject
]

{ #category : 'accessing' }
CPProcessDesignNode >> metadata [
	^ metadata
]

{ #category : 'accessing' }
CPProcessDesignNode >> metadata: anObject [
	metadata := anObject
]

{ #category : 'initialization' }
CPProcessDesignNode >> initialize [
	super initialize.
	metadata := Dictionary new
]

{ #category : 'testing' }
CPProcessDesignNode >> isStartNode [
	^ false
]

{ #category : 'testing' }
CPProcessDesignNode >> isEndNode [
	^ false
]

{ #category : 'testing' }
CPProcessDesignNode >> isTaskNode [
	^ false
]

{ #category : 'testing' }
CPProcessDesignNode >> isGatewayNode [
	^ false
]

{ #category : 'descriptions' }
CPProcessDesignNode >> commentDescription [
	<magritteDescription>
	^ MAMemoDescription new
		accessor: #comment;
		label: 'Comment';
		priority: 100;
		group: 'General';
		yourself
]

{ #category : 'descriptions' }
CPProcessDesignNode >> positionDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #position;
		label: 'Position';
		priority: 110;
		group: 'Relations';
		yourself
]

{ #category : 'descriptions' }
CPProcessDesignNode >> metadataDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #metadata;
		label: 'Metadata';
		priority: 120;
		group: 'Relations';
		yourself
]

