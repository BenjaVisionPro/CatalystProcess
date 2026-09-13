Class {
	#name : 'CPDataInput',
	#superclass : 'CPItemAwareElement',
	#instVars : [ 'isCollection' ],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'initialization' }
CPDataInput >> initialize [ super initialize. isCollection := false ]
{ #category : 'accessing' }
CPDataInput >> isCollection [
	^ self itemSubjectRef
		ifNil: [ isCollection ]
		ifNotNil: [ self itemSubjectRef isCollection ]
]
{ #category : 'accessing' }
CPDataInput >> isCollection: aBoolean [ isCollection := aBoolean ]
{ #category : 'descriptions' }
CPDataInput >> isCollectionDescription [
	<magritteDescription>
	^ MABooleanDescription new accessor: #isCollection; label: 'Collection'; priority: 120; group: 'Data'; yourself
]
