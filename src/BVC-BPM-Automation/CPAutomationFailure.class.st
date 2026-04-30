Class {
	#name : 'CPAutomationFailure',
	#superclass : 'CFObject',
	#instVars : [
		'message',
		'details'
	],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'accessing' }
CPAutomationFailure >> message [
	^ message
]

{ #category : 'accessing' }
CPAutomationFailure >> message: anObject [
	message := anObject
]

{ #category : 'accessing' }
CPAutomationFailure >> details [
	^ details
]

{ #category : 'accessing' }
CPAutomationFailure >> details: anObject [
	details := anObject
]

