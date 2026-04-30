Class {
	#name : 'CPProcessDesignValidatorTest',
	#superclass : 'TestCase',
	#category : 'BVC-BPM-Tests',
	#package : 'BVC-BPM-Tests'
}

{ #category : 'tests' }
CPProcessDesignValidatorTest >> testSimpleUserTaskDesignIsValid [
	| result |
	result := CPProcessExamples new simpleUserTaskDesign validate.
	self assert: result isValid
]

