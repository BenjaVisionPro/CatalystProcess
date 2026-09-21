Class {
	#name : 'CPBpmService',
	#superclass : 'CRWorkerService',
	#instVars : [
		'systemRoot'
	],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'configuration' }
CPBpmService class >> configurationClass [
	^ CPBpmServiceConfiguration
]

{ #category : 'configuration' }
CPBpmService class >> appearsInServiceAddMenu [
	^ self == CPBpmService
]

{ #category : 'configuration' }
CPBpmService class >> isSingletonService [
	^ self == CPBpmService
]

{ #category : 'configuration' }
CPBpmService class >> serviceAddMenuDisplayName [
	^ 'BPM'
]

{ #category : 'accessing' }
CPBpmService >> systemRoot [
	^ systemRoot
]

{ #category : 'lifecycle' }
CPBpmService >> installWithConfiguration: aCPBpmServiceConfiguration [
	aCPBpmServiceConfiguration ifNil: [
		self error: 'BPM service configuration must not be nil.' ].
	aCPBpmServiceConfiguration systemRoot ifNil: [
		self error: 'BPM service configuration requires a system root.' ].
	configuration := aCPBpmServiceConfiguration.
	systemRoot := aCPBpmServiceConfiguration systemRoot.
	^ self
]

{ #category : 'execution lookup' }
CPBpmService >> processExecutionForIdentifier: anExecutionIdentifier [
	^ systemRoot processExecutionForIdentifier: anExecutionIdentifier
]
