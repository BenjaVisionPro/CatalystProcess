Class {
	#name : 'CPExecutionOccurrence',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'occurrenceIdentifier',
		'definition',
		'payload',
		'acceptedAt'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'initialization' }
CPExecutionOccurrence >> initialize [
	super initialize.
	payload := Dictionary new
]

{ #category : 'accessing' }
CPExecutionOccurrence >> occurrenceIdentifier [ ^ occurrenceIdentifier ]
{ #category : 'accessing' }
CPExecutionOccurrence >> occurrenceIdentifier: anObject [ occurrenceIdentifier := anObject ]
{ #category : 'accessing' }
CPExecutionOccurrence >> definition [ ^ definition ]
{ #category : 'accessing' }
CPExecutionOccurrence >> definition: anObject [ definition := anObject ]
{ #category : 'accessing' }
CPExecutionOccurrence >> payload [ ^ payload ]
{ #category : 'accessing' }
CPExecutionOccurrence >> payload: aDictionary [ payload := aDictionary ]
{ #category : 'accessing' }
CPExecutionOccurrence >> acceptedAt [ ^ acceptedAt ]
{ #category : 'accessing' }
CPExecutionOccurrence >> acceptedAt: aDateAndTime [ acceptedAt := aDateAndTime ]
