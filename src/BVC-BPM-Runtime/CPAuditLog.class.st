Class {
	#name : 'CPAuditLog',
	#superclass : 'CFObject',
	#instVars : [
		'events'
	],
	#category : 'BVC-BPM-Runtime',
	#package : 'BVC-BPM-Runtime'
}

{ #category : 'accessing' }
CPAuditLog >> events [
	^ events
]

{ #category : 'accessing' }
CPAuditLog >> events: anObject [
	events := anObject
]

{ #category : 'initialization' }
CPAuditLog >> initialize [
	super initialize.
	events := OrderedCollection new
]

{ #category : 'adding' }
CPAuditLog >> append: anEvent [
	events add: anEvent.
	^ anEvent
]

