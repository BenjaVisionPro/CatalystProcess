Class {
	#name : 'CPAutomationResult',
	#superclass : 'CFObject',
	#instVars : [
		'payload'
	],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'accessing' }
CPAutomationResult >> payload [
	^ payload
]

{ #category : 'accessing' }
CPAutomationResult >> payload: anObject [
	payload := anObject
]

