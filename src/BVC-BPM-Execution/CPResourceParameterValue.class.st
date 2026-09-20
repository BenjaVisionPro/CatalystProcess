Class {
	#name : 'CPResourceParameterValue',
	#superclass : 'Object',
	#instVars : [ 'parameter', 'value' ],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'accessing' }
CPResourceParameterValue >> parameter [ ^ parameter ]

{ #category : 'accessing' }
CPResourceParameterValue >> parameter: aResourceParameter [
	parameter ifNotNil: [ self error: 'A Resource parameter value can reference only one parameter.' ].
	aResourceParameter ifNil: [ self error: 'A Resource parameter value requires a parameter.' ].
	parameter := aResourceParameter
]

{ #category : 'accessing' }
CPResourceParameterValue >> value [ ^ value ]

{ #category : 'accessing' }
CPResourceParameterValue >> value: anObject [
	value := anObject
]
