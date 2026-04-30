Class {
	#name : 'CPRuntimeResult',
	#superclass : 'CFObject',
	#instVars : [
		'value',
		'errors'
	],
	#category : 'BVC-BPM-Runtime',
	#package : 'BVC-BPM-Runtime'
}

{ #category : 'accessing' }
CPRuntimeResult >> value [
	^ value
]

{ #category : 'accessing' }
CPRuntimeResult >> value: anObject [
	value := anObject
]

{ #category : 'accessing' }
CPRuntimeResult >> errors [
	^ errors
]

{ #category : 'accessing' }
CPRuntimeResult >> errors: anObject [
	errors := anObject
]

{ #category : 'initialization' }
CPRuntimeResult >> initialize [
	super initialize.
	errors := OrderedCollection new
]

