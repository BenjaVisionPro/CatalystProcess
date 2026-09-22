Class {
	#name : 'CPQueryStartableProcessDeploymentsWorkUnit',
	#superclass : 'CRWorkUnit',
	#instVars : [
		'user'
	],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'instance creation' }
CPQueryStartableProcessDeploymentsWorkUnit class >> user: aUser [
	^ self new user: aUser; yourself
]

{ #category : 'service context' }
CPQueryStartableProcessDeploymentsWorkUnit class >> serviceClass [
	^ CPBpmService
]

{ #category : 'accessing' }
CPQueryStartableProcessDeploymentsWorkUnit >> user [
	^ user
]

{ #category : 'accessing' }
CPQueryStartableProcessDeploymentsWorkUnit >> user: aUser [
	user := aUser
]

{ #category : 'running' }
CPQueryStartableProcessDeploymentsWorkUnit >> executeInContext: aCRWorkUnitExecutionContext [
	^ aCRWorkUnitExecutionContext service queryStartableProcessDeploymentsWorkUnit: self
]
