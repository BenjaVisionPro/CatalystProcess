Class {
	#name : 'CPNodeDefinition',
	#superclass : 'CFLabelledObject',
	#instVars : [
		'comment',
		'sourceDesignNode'
	],
	#category : 'BVC-BPM-Definition',
	#package : 'BVC-BPM-Definition'
}

{ #category : 'accessing' }
CPNodeDefinition >> comment [
	^ comment
]

{ #category : 'accessing' }
CPNodeDefinition >> comment: anObject [
	comment := anObject
]

{ #category : 'accessing' }
CPNodeDefinition >> sourceDesignNode [
	^ sourceDesignNode
]

{ #category : 'accessing' }
CPNodeDefinition >> sourceDesignNode: anObject [
	sourceDesignNode := anObject
]

{ #category : 'testing' }
CPNodeDefinition >> isStartNode [
	^ false
]

{ #category : 'testing' }
CPNodeDefinition >> isEndNode [
	^ false
]

{ #category : 'testing' }
CPNodeDefinition >> isUserTask [
	^ false
]

{ #category : 'testing' }
CPNodeDefinition >> isServiceTask [
	^ false
]

{ #category : 'testing' }
CPNodeDefinition >> isGateway [
	^ false
]

