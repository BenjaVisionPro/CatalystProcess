Class {
	#name : 'CPProcessCompilerTest',
	#superclass : 'TestCase',
	#category : 'BVC-BPM-Tests',
	#package : 'BVC-BPM-Tests'
}

{ #category : 'tests' }
CPProcessCompilerTest >> testSimpleUserTaskDesignCompiles [
	| result |
	result := CPProcessExamples new compiledSimpleUserTaskDefinition.
	self assert: result isSuccess.
	self assert: result compiledDefinition startNode notNil
]

