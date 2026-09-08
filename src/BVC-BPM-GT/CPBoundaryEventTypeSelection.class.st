Class {
	#name : 'CPBoundaryEventTypeSelection',
	#superclass : 'CPFlowNodeTypeSelection',
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}
{ #category : 'type protocol' }
CPBoundaryEventTypeSelection >> typeClasses [ ^ CPBoundaryEvent eventDefinitionTypes ]
{ #category : 'type protocol' }
CPBoundaryEventTypeSelection >> typeDescriptionLabel [ ^ 'Boundary event type' ]
{ #category : 'type protocol' }
CPBoundaryEventTypeSelection >> typeLabelFor: aClass [ ^ aClass eventTypeLabel ]
{ #category : 'type protocol' }
CPBoundaryEventTypeSelection >> typeIconFor: aClass [ ^ aClass eventTypeIcon ]
