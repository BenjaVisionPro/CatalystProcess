"I am the Foundation editing transaction for a source-backed CPDefinitions.

I keep source persistence at the Process Atelier boundary: ordinary CFMaMemento still owns staged model editing, while my commit first writes the validated Process source changes to the source class and then performs the normal Foundation commit."
Class {
	#name : 'CPDefinitionsSourceMemento',
	#superclass : 'CFMaMemento',
	#instVars : [
		'sourceClass'
	],
	#category : 'BVC-BPM-Atelier-Source',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Source'
}

{ #category : 'instance creation' }
CPDefinitionsSourceMemento class >> model: aDefinitions sourceClass: aSourceClass [
	^ (self model: aDefinitions)
		sourceClass: aSourceClass;
		yourself
]

{ #category : 'accessing' }
CPDefinitionsSourceMemento >> sourceClass [
	^ sourceClass
]

{ #category : 'accessing' }
CPDefinitionsSourceMemento >> sourceClass: aSourceClass [
	sourceClass := aSourceClass
]

{ #category : 'actions' }
CPDefinitionsSourceMemento >> commit [
	CPDefinitionsSourceMaterializer new
		saveSourceChangesFromMemento: self
		in: sourceClass.
	^ super commit
]

{ #category : 'private - children' }
CPDefinitionsSourceMemento >> newChildMementoFor: anObject [
	^ (CFMaMemento model: anObject)
		parentMemento: self;
		yourself
]
