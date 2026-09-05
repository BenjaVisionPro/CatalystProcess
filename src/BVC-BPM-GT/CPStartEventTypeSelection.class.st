Class {
	#name : 'CPStartEventTypeSelection',
	#superclass : 'CPFlowNodeTypeSelection',
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}
{ #category : 'type protocol' }
CPStartEventTypeSelection >> typeClasses [ ^ CPStartEvent startEventTypes ]
{ #category : 'type protocol' }
CPStartEventTypeSelection >> typeDescriptionLabel [ ^ 'Start event type' ]
{ #category : 'type protocol' }
CPStartEventTypeSelection >> typeLabelFor: aClass [ ^ aClass eventTypeLabel ]
{ #category : 'type protocol' }
CPStartEventTypeSelection >> typeIconFor: aClass [ ^ aClass eventTypeIcon ]
