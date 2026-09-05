Class {
	#name : 'CPIntermediateEventTypeSelection',
	#superclass : 'CPFlowNodeTypeSelection',
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}
{ #category : 'type protocol' }
CPIntermediateEventTypeSelection >> typeClasses [ ^ CPIntermediateEvent eventTypes ]
{ #category : 'type protocol' }
CPIntermediateEventTypeSelection >> typeDescriptionLabel [ ^ 'Event type' ]
{ #category : 'type protocol' }
CPIntermediateEventTypeSelection >> typeLabelFor: aClass [ ^ aClass eventTypeLabel ]
{ #category : 'type protocol' }
CPIntermediateEventTypeSelection >> typeIconFor: aClass [ ^ aClass eventTypeIcon ]
