Class {
	#name : 'CPProcessCompilationResult',
	#superclass : 'CFObject',
	#instVars : [
		'definition',
		'compiledDefinition',
		'validation'
	],
	#category : 'BVC-BPM-Definition',
	#package : 'BVC-BPM-Definition'
}

{ #category : 'instance creation' }
CPProcessCompilationResult class >> definition: aDefinition compiledDefinition: aCompiledDefinition validation: aValidationResult [
	^ self new
		definition: aDefinition;
		compiledDefinition: aCompiledDefinition;
		validation: aValidationResult;
		yourself
]

{ #category : 'instance creation' }
CPProcessCompilationResult class >> failedValidation: aValidationResult [
	^ self new
		validation: aValidationResult;
		yourself
]

{ #category : 'accessing' }
CPProcessCompilationResult >> definition [
	^ definition
]

{ #category : 'accessing' }
CPProcessCompilationResult >> definition: anObject [
	definition := anObject
]

{ #category : 'accessing' }
CPProcessCompilationResult >> compiledDefinition [
	^ compiledDefinition
]

{ #category : 'accessing' }
CPProcessCompilationResult >> compiledDefinition: anObject [
	compiledDefinition := anObject
]

{ #category : 'accessing' }
CPProcessCompilationResult >> validation [
	^ validation
]

{ #category : 'accessing' }
CPProcessCompilationResult >> validation: anObject [
	validation := anObject
]

{ #category : 'testing' }
CPProcessCompilationResult >> isSuccess [
	^ compiledDefinition notNil and: [ validation notNil and: [ validation isValid ] ]
]

