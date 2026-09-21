Class {
	#name : 'CPDeliverProcessInitiationOccurrenceWorkUnit',
	#superclass : 'CRWorkUnit',
	#instVars : [ 'initiationSubscription', 'occurrence' ],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'service context' }
CPDeliverProcessInitiationOccurrenceWorkUnit class >> serviceClass [ ^ CPBpmService ]
{ #category : 'instance creation' }
CPDeliverProcessInitiationOccurrenceWorkUnit class >> initiationSubscription: aSubscription occurrence: anOccurrence [
	^ self new initiationSubscription: aSubscription; occurrence: anOccurrence; yourself
]
{ #category : 'accessing' }
CPDeliverProcessInitiationOccurrenceWorkUnit >> initiationSubscription [ ^ initiationSubscription ]
{ #category : 'accessing' }
CPDeliverProcessInitiationOccurrenceWorkUnit >> initiationSubscription: anObject [ initiationSubscription := anObject ]
{ #category : 'accessing' }
CPDeliverProcessInitiationOccurrenceWorkUnit >> occurrence [ ^ occurrence ]
{ #category : 'accessing' }
CPDeliverProcessInitiationOccurrenceWorkUnit >> occurrence: anObject [ occurrence := anObject ]
{ #category : 'running' }
CPDeliverProcessInitiationOccurrenceWorkUnit >> executeInContext: aContext [
	^ aContext service deliverProcessInitiationOccurrenceWorkUnit: self
]
