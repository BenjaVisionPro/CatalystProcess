Class {
	#name : 'CPBpmServiceConfiguration',
	#superclass : 'CRServiceConfiguration',
	#instVars : [
		'systemRoot'
	],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'initialization' }
CPBpmServiceConfiguration >> initialize [
	super initialize.
	self serviceClass: CPBpmService.
	systemRoot := CPSystemRoot new
]

{ #category : 'accessing' }
CPBpmServiceConfiguration >> systemRoot [
	^ systemRoot
]

{ #category : 'accessing' }
CPBpmServiceConfiguration >> systemRoot: anObject [
	systemRoot := anObject
]
