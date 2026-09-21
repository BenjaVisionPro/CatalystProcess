Class {
	#name : 'CPParallelMultipleStartInitiation',
	#superclass : 'CFIdentifiableObject',
	#instVars : [ 'processDeployment', 'startEvent', 'occurrencesByDefinition' ],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'initialization' }
CPParallelMultipleStartInitiation >> initialize [
	super initialize.
	occurrencesByDefinition := IdentityDictionary new
]

{ #category : 'accessing' }
CPParallelMultipleStartInitiation >> processDeployment [ ^ processDeployment ]
{ #category : 'accessing' }
CPParallelMultipleStartInitiation >> processDeployment: anObject [ processDeployment := anObject ]
{ #category : 'accessing' }
CPParallelMultipleStartInitiation >> startEvent [ ^ startEvent ]
{ #category : 'accessing' }
CPParallelMultipleStartInitiation >> startEvent: anObject [ startEvent := anObject ]

{ #category : 'process initiation' }
CPParallelMultipleStartInitiation >> acceptOccurrence: anOccurrence forDefinition: anEventDefinition usingService: aBpmService [
	| occurrences execution |
	(startEvent eventDefinitions identityIncludes: anEventDefinition) ifFalse: [
		self error: 'The Event Definition does not belong to this Parallel Multiple Start Event.' ].
	(occurrencesByDefinition includesKey: anEventDefinition) ifFalse: [
		occurrencesByDefinition at: anEventDefinition put: anOccurrence ].
	occurrencesByDefinition size = startEvent eventDefinitions size ifFalse: [ ^ nil ].
	occurrences := startEvent eventDefinitions collect: [ :each | occurrencesByDefinition at: each ].
	execution := aBpmService
		instantiateParallelMultipleStartEvent: startEvent
		fromDeployment: processDeployment
		occurrences: occurrences.
	occurrencesByDefinition removeAll.
	^ execution
]
