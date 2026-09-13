"I represent a source Link Intermediate Event, which throws control to one or more matching target Link Intermediate Catch Events."
Class {
	#name : 'CPLinkThrowIntermediateEvent',
	#superclass : 'CPIntermediateThrowEvent',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}
{ #category : 'event type' }
CPLinkThrowIntermediateEvent class >> eventTypeLabel [ ^ 'Link Throw' ]
{ #category : 'event type' }
CPLinkThrowIntermediateEvent class >> eventTypeIcon [ ^ #link ]
