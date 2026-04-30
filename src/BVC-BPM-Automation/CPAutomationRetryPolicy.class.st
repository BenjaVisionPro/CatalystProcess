Class {
	#name : 'CPAutomationRetryPolicy',
	#superclass : 'CFObject',
	#instVars : [
		'maxAttempts'
	],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'accessing' }
CPAutomationRetryPolicy >> maxAttempts [
	^ maxAttempts
]

{ #category : 'accessing' }
CPAutomationRetryPolicy >> maxAttempts: anObject [
	maxAttempts := anObject
]

