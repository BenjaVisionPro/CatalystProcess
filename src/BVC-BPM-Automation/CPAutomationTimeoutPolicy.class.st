Class {
	#name : 'CPAutomationTimeoutPolicy',
	#superclass : 'CFObject',
	#instVars : [
		'duration'
	],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'accessing' }
CPAutomationTimeoutPolicy >> duration [
	^ duration
]

{ #category : 'accessing' }
CPAutomationTimeoutPolicy >> duration: anObject [
	duration := anObject
]

