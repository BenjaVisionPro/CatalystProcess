Class {
	#name : 'CPEndEventTypeSelection',
	#superclass : 'CPFlowNodeTypeSelection',
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}
{ #category : 'type protocol' }
CPEndEventTypeSelection >> typeClasses [ ^ CPEndEvent endEventTypes ]
{ #category : 'type protocol' }
CPEndEventTypeSelection >> typeDescriptionLabel [ ^ 'End event type' ]
{ #category : 'type protocol' }
CPEndEventTypeSelection >> typeLabelFor: aClass [ ^ aClass eventTypeLabel ]
{ #category : 'type protocol' }
CPEndEventTypeSelection >> typeIconFor: aClass [ ^ aClass eventTypeIcon ]
