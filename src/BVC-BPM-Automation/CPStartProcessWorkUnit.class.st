Class {
	#name : 'CPStartProcessWorkUnit',
	#superclass : 'CRWorkUnit',
	#instVars : [
		'processDeployment',
		'user'
	],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'service context' }
CPStartProcessWorkUnit class >> serviceClass [ ^ CPBpmService ]

{ #category : 'instance creation' }
CPStartProcessWorkUnit class >> processDeployment: aCPProcessDeployment user: aUser [
	^ self new processDeployment: aCPProcessDeployment; user: aUser; yourself
]

{ #category : 'accessing' }
CPStartProcessWorkUnit >> processDeployment [ ^ processDeployment ]

{ #category : 'accessing' }
CPStartProcessWorkUnit >> processDeployment: aCPProcessDeployment [ processDeployment := aCPProcessDeployment ]

{ #category : 'accessing' }
CPStartProcessWorkUnit >> user [ ^ user ]

{ #category : 'accessing' }
CPStartProcessWorkUnit >> user: aUser [ user := aUser ]

{ #category : 'running' }
CPStartProcessWorkUnit >> executeInContext: aCRWorkUnitExecutionContext [
	^ aCRWorkUnitExecutionContext service startProcessWorkUnit: self
]
