Class {
	#name : 'CPDataOutput',
	#superclass : 'CPItemAwareElement',
	#instVars : [ 'isCollection' ],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'initialization' }
CPDataOutput >> initialize [ super initialize. isCollection := false ]
{ #category : 'accessing' }
CPDataOutput >> isCollection [
	^ self itemSubjectRef
		ifNil: [ isCollection ]
		ifNotNil: [ self itemSubjectRef isCollection ]
]
{ #category : 'accessing' }
CPDataOutput >> isCollection: aBoolean [ isCollection := aBoolean ]
{ #category : 'descriptions' }
CPDataOutput >> isCollectionDescription [
	<magritteDescription>
	^ MABooleanDescription new accessor: #isCollection; label: 'Collection'; priority: 120; group: 'Data'; yourself
]
