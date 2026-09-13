"I represent the existing Signal Intermediate Catch Event. The receive icon and CatchEvent inheritance make its receiving semantics explicit."
Class {
	#name : 'CPSignalIntermediateEvent',
	#superclass : 'CPIntermediateCatchEvent',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}
{ #category : 'event type' }
CPSignalIntermediateEvent class >> eventTypeLabel [ ^ 'Signal' ]
{ #category : 'event type' }
CPSignalIntermediateEvent class >> eventTypeIcon [ ^ #towerReceive ]
