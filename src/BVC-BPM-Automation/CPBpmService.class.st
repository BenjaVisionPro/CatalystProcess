Class {
	#name : 'CPBpmService',
	#superclass : 'CFLabelledObject',
	#instVars : [
		'systemRoot',
		'runtimeEngine'
	],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'accessing' }
CPBpmService >> systemRoot [
	^ systemRoot
]

{ #category : 'accessing' }
CPBpmService >> systemRoot: anObject [
	systemRoot := anObject
]

{ #category : 'accessing' }
CPBpmService >> runtimeEngine [
	^ runtimeEngine
]

{ #category : 'accessing' }
CPBpmService >> runtimeEngine: anObject [
	runtimeEngine := anObject
]

{ #category : 'initialization' }
CPBpmService >> initialize [
	super initialize.
	systemRoot := CPSystemRoot new.
	runtimeEngine := CPRuntimeEngine new
]

