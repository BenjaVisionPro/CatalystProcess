Class {
	#name : 'CPTransitionDefinition',
	#superclass : 'CFLabelledObject',
	#instVars : [
		'comment',
		'sourceNode',
		'targetNode',
		'condition',
		'isDefault',
		'sourceDesignEdge'
	],
	#category : 'BVC-BPM-Definition',
	#package : 'BVC-BPM-Definition'
}

{ #category : 'accessing' }
CPTransitionDefinition >> comment [
	^ comment
]

{ #category : 'accessing' }
CPTransitionDefinition >> comment: anObject [
	comment := anObject
]

{ #category : 'accessing' }
CPTransitionDefinition >> sourceNode [
	^ sourceNode
]

{ #category : 'accessing' }
CPTransitionDefinition >> sourceNode: anObject [
	sourceNode := anObject
]

{ #category : 'accessing' }
CPTransitionDefinition >> targetNode [
	^ targetNode
]

{ #category : 'accessing' }
CPTransitionDefinition >> targetNode: anObject [
	targetNode := anObject
]

{ #category : 'accessing' }
CPTransitionDefinition >> condition [
	^ condition
]

{ #category : 'accessing' }
CPTransitionDefinition >> condition: anObject [
	condition := anObject
]

{ #category : 'accessing' }
CPTransitionDefinition >> isDefault [
	^ isDefault
]

{ #category : 'accessing' }
CPTransitionDefinition >> isDefault: anObject [
	isDefault := anObject
]

{ #category : 'accessing' }
CPTransitionDefinition >> sourceDesignEdge [
	^ sourceDesignEdge
]

{ #category : 'accessing' }
CPTransitionDefinition >> sourceDesignEdge: anObject [
	sourceDesignEdge := anObject
]

{ #category : 'initialization' }
CPTransitionDefinition >> initialize [
	super initialize.
	isDefault := false
]

{ #category : 'accessing' }
CPTransitionDefinition >> beDefault [
	isDefault := true
]

