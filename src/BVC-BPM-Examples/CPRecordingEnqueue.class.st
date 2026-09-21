Class {
	#name : 'CPRecordingEnqueue',
	#superclass : 'Object',
	#instVars : [ 'workUnits' ],
	#category : 'BVC-BPM-Examples',
	#package : 'BVC-BPM-Examples'
}

{ #category : 'initialization' }
CPRecordingEnqueue >> initialize [
	super initialize.
	workUnits := OrderedCollection new
]

{ #category : 'queue' }
CPRecordingEnqueue >> enqueue: aWorkUnit [
	workUnits add: aWorkUnit.
	^ aWorkUnit
]

{ #category : 'accessing' }
CPRecordingEnqueue >> workUnits [ ^ workUnits ]
