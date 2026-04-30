Class {
	#name : 'CPProcessDefinition',
	#superclass : 'CFLabelledObject',
	#instVars : [
		'processKey',
		'comment',
		'sourceDesign',
		'nodes',
		'transitions',
		'createdAt'
	],
	#category : 'BVC-BPM-Definition',
	#package : 'BVC-BPM-Definition'
}

{ #category : 'accessing' }
CPProcessDefinition >> processKey [
	^ processKey
]

{ #category : 'accessing' }
CPProcessDefinition >> processKey: anObject [
	processKey := anObject
]

{ #category : 'accessing' }
CPProcessDefinition >> comment [
	^ comment
]

{ #category : 'accessing' }
CPProcessDefinition >> comment: anObject [
	comment := anObject
]

{ #category : 'accessing' }
CPProcessDefinition >> sourceDesign [
	^ sourceDesign
]

{ #category : 'accessing' }
CPProcessDefinition >> sourceDesign: anObject [
	sourceDesign := anObject
]

{ #category : 'accessing' }
CPProcessDefinition >> nodes [
	^ nodes
]

{ #category : 'accessing' }
CPProcessDefinition >> nodes: anObject [
	nodes := anObject
]

{ #category : 'accessing' }
CPProcessDefinition >> transitions [
	^ transitions
]

{ #category : 'accessing' }
CPProcessDefinition >> transitions: anObject [
	transitions := anObject
]

{ #category : 'accessing' }
CPProcessDefinition >> createdAt [
	^ createdAt
]

{ #category : 'accessing' }
CPProcessDefinition >> createdAt: anObject [
	createdAt := anObject
]

{ #category : 'initialization' }
CPProcessDefinition >> initialize [
	super initialize.
	nodes := OrderedCollection new.
	transitions := OrderedCollection new.
	createdAt := DateAndTime now
]

