Class {
	#name : 'CPRetireProcessDeploymentWorkUnit',
	#superclass : 'CRWorkUnit',
	#instVars : [ 'processDeployment' ],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'service context' }
CPRetireProcessDeploymentWorkUnit class >> serviceClass [ ^ CPBpmService ]

{ #category : 'instance creation' }
CPRetireProcessDeploymentWorkUnit class >> processDeployment: aCPProcessDeployment [
	^ self new processDeployment: aCPProcessDeployment; yourself
]

{ #category : 'accessing' }
CPRetireProcessDeploymentWorkUnit >> processDeployment [ ^ processDeployment ]

{ #category : 'accessing' }
CPRetireProcessDeploymentWorkUnit >> processDeployment: aCPProcessDeployment [ processDeployment := aCPProcessDeployment ]

{ #category : 'running' }
CPRetireProcessDeploymentWorkUnit >> executeInContext: aCRWorkUnitExecutionContext [
	^ aCRWorkUnitExecutionContext service retireProcessDeploymentWorkUnit: self
]
