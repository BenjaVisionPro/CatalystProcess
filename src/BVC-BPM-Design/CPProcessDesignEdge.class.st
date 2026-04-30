Class {
	#name : 'CPProcessDesignEdge',
	#superclass : 'CFLabelledObject',
	#instVars : [
		'comment',
		'sourceNode',
		'targetNode',
		'condition',
		'isDefault',
		'metadata'
	],
	#category : 'BVC-BPM-Design',
	#package : 'BVC-BPM-Design'
}

{ #category : 'accessing' }
CPProcessDesignEdge >> comment [
	^ comment
]

{ #category : 'accessing' }
CPProcessDesignEdge >> comment: anObject [
	comment := anObject
]

{ #category : 'accessing' }
CPProcessDesignEdge >> sourceNode [
	^ sourceNode
]

{ #category : 'accessing' }
CPProcessDesignEdge >> sourceNode: anObject [
	sourceNode := anObject
]

{ #category : 'accessing' }
CPProcessDesignEdge >> targetNode [
	^ targetNode
]

{ #category : 'accessing' }
CPProcessDesignEdge >> targetNode: anObject [
	targetNode := anObject
]

{ #category : 'accessing' }
CPProcessDesignEdge >> condition [
	^ condition
]

{ #category : 'accessing' }
CPProcessDesignEdge >> condition: anObject [
	condition := anObject
]

{ #category : 'accessing' }
CPProcessDesignEdge >> isDefault [
	^ isDefault
]

{ #category : 'accessing' }
CPProcessDesignEdge >> isDefault: anObject [
	isDefault := anObject
]

{ #category : 'accessing' }
CPProcessDesignEdge >> metadata [
	^ metadata
]

{ #category : 'accessing' }
CPProcessDesignEdge >> metadata: anObject [
	metadata := anObject
]

{ #category : 'initialization' }
CPProcessDesignEdge >> initialize [
	super initialize.
	isDefault := false.
	metadata := Dictionary new
]

{ #category : 'accessing' }
CPProcessDesignEdge >> beDefault [
	isDefault := true
]

{ #category : 'descriptions' }
CPProcessDesignEdge >> commentDescription [
	<magritteDescription>
	^ MAMemoDescription new
		accessor: #comment;
		label: 'Comment';
		priority: 100;
		cfCategory: #general;
		yourself
]

{ #category : 'descriptions' }
CPProcessDesignEdge >> sourceNodeDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #sourceNode;
		label: 'Source node';
		priority: 110;
		cfCategory: #relations;
		yourself
]

{ #category : 'descriptions' }
CPProcessDesignEdge >> targetNodeDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #targetNode;
		label: 'Target node';
		priority: 120;
		cfCategory: #relations;
		yourself
]

{ #category : 'descriptions' }
CPProcessDesignEdge >> conditionDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #condition;
		label: 'Condition';
		priority: 130;
		cfCategory: #relations;
		yourself
]

