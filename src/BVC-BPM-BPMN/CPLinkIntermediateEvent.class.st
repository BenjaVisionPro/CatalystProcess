"I represent a target Link Intermediate Event, which catches control transferred by a source Link Intermediate Throw Event."
Class {
	#name : 'CPLinkIntermediateEvent',
	#superclass : 'CPIntermediateCatchEvent',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}
{ #category : 'event type' }
CPLinkIntermediateEvent class >> eventTypeLabel [ ^ 'Link Catch' ]
{ #category : 'event type' }
CPLinkIntermediateEvent class >> eventTypeIcon [ ^ #link ]
