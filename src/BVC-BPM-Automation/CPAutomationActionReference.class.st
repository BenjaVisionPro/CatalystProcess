Class {
	#name : 'CPAutomationActionReference',
	#superclass : 'CFLabelledObject',
	#instVars : [
		'actionName',
		'inputMapping',
		'outputMapping',
		'retryPolicy',
		'timeoutPolicy'
	],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'accessing' }
CPAutomationActionReference >> actionName [
	^ actionName
]

{ #category : 'accessing' }
CPAutomationActionReference >> actionName: anObject [
	actionName := anObject
]

{ #category : 'accessing' }
CPAutomationActionReference >> inputMapping [
	^ inputMapping
]

{ #category : 'accessing' }
CPAutomationActionReference >> inputMapping: anObject [
	inputMapping := anObject
]

{ #category : 'accessing' }
CPAutomationActionReference >> outputMapping [
	^ outputMapping
]

{ #category : 'accessing' }
CPAutomationActionReference >> outputMapping: anObject [
	outputMapping := anObject
]

{ #category : 'accessing' }
CPAutomationActionReference >> retryPolicy [
	^ retryPolicy
]

{ #category : 'accessing' }
CPAutomationActionReference >> retryPolicy: anObject [
	retryPolicy := anObject
]

{ #category : 'accessing' }
CPAutomationActionReference >> timeoutPolicy [
	^ timeoutPolicy
]

{ #category : 'accessing' }
CPAutomationActionReference >> timeoutPolicy: anObject [
	timeoutPolicy := anObject
]

