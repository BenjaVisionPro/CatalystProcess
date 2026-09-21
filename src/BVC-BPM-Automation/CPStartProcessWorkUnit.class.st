Class {
	#name : 'CPStartProcessWorkUnit',
	#superclass : 'CRWorkUnit',
	#instVars : [
		'processDeployment'
	],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'service context' }
CPStartProcessWorkUnit class >> serviceClass [ ^ CPBpmService ]

{ #category : 'instance creation' }
CPStartProcessWorkUnit class >> processDeployment: aCPProcessDeployment [
	^ self new processDeployment: aCPProcessDeployment; yourself
]

{ #category : 'accessing' }
CPStartProcessWorkUnit >> processDeployment [ ^ processDeployment ]

{ #category : 'accessing' }
CPStartProcessWorkUnit >> processDeployment: aCPProcessDeployment [ processDeployment := aCPProcessDeployment ]

{ #category : 'running' }
CPStartProcessWorkUnit >> executeInContext: aCRWorkUnitExecutionContext [
	^ aCRWorkUnitExecutionContext service startProcessWorkUnit: self
]
