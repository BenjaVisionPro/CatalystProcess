Class {
	#name : 'CPBpmServiceConfiguration',
	#superclass : 'CRServiceConfiguration',
	#instVars : [
		'systemRoot',
		'backgroundScheduleKey',
		'backgroundIntervalMillis',
		'executionEnvironment'
	],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'initialization' }
CPBpmServiceConfiguration >> initialize [
	super initialize.
	self
		identifier: #bpm;
		label: 'BPM';
		serviceClass: CPBpmService.
	systemRoot := CPSystemRoot new.
	backgroundScheduleKey := #bpmBackgroundProcessing.
	backgroundIntervalMillis := 1000
]

{ #category : 'accessing' }
CPBpmServiceConfiguration >> systemRoot [
	^ systemRoot
]

{ #category : 'accessing' }
CPBpmServiceConfiguration >> systemRoot: anObject [
	systemRoot := anObject
]


{ #category : 'background processing' }
CPBpmServiceConfiguration >> backgroundScheduleKey [
	^ backgroundScheduleKey
]

{ #category : 'background processing' }
CPBpmServiceConfiguration >> backgroundScheduleKey: aSymbol [
	aSymbol isSymbol ifFalse: [ self error: 'BPM background schedule key must be a Symbol.' ].
	backgroundScheduleKey := aSymbol
]

{ #category : 'background processing' }
CPBpmServiceConfiguration >> backgroundIntervalMillis [
	^ backgroundIntervalMillis
]

{ #category : 'background processing' }
CPBpmServiceConfiguration >> backgroundIntervalMillis: anInteger [
	anInteger isInteger ifFalse: [ self error: 'BPM background interval must be an Integer.' ].
	anInteger <= 0 ifTrue: [ self error: 'BPM background interval must be positive.' ].
	backgroundIntervalMillis := anInteger
]


{ #category : 'execution environment' }
CPBpmServiceConfiguration >> executionEnvironment [
	^ executionEnvironment
]

{ #category : 'execution environment' }
CPBpmServiceConfiguration >> executionEnvironment: anExecutionEnvironment [
	executionEnvironment := anExecutionEnvironment
]
