"I bind one concrete BPMN Operation object from an immutable Operational Release to the implementation selected for that release. I do not interpret Operation identifiers and I do not execute work."
Class {
	#name : 'CPOperationImplementationBinding',
	#superclass : 'Object',
	#instVars : [ 'operation', 'implementation' ],
	#category : 'BVC-BPM-Marketplace-Domain',
	#package : 'BVC-BPM-Marketplace',
	#tag : 'Domain'
}

{ #category : 'instance creation' }
CPOperationImplementationBinding class >> operation: anOperation implementation: anImplementation [
	^ self new
		operation: anOperation;
		implementation: anImplementation;
		yourself
]

{ #category : 'accessing' }
CPOperationImplementationBinding >> operation [
	^ operation
]

{ #category : 'private' }
CPOperationImplementationBinding >> operation: anOperation [
	anOperation ifNil: [ self error: 'An Operation binding requires an Operation.' ].
	operation ifNotNil: [ self error: 'An Operation binding Operation can be assigned only once.' ].
	operation := anOperation
]

{ #category : 'accessing' }
CPOperationImplementationBinding >> implementation [
	^ implementation
]

{ #category : 'private' }
CPOperationImplementationBinding >> implementation: anImplementation [
	anImplementation ifNil: [ self error: 'An Operation binding requires an implementation.' ].
	implementation ifNotNil: [ self error: 'An Operation binding implementation can be assigned only once.' ].
	implementation := anImplementation
]
