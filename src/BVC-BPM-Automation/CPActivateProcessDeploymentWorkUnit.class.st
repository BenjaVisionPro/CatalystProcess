Class {
	#name : 'CPActivateProcessDeploymentWorkUnit',
	#superclass : 'CRWorkUnit',
	#instVars : [ 'processDeployment' ],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'service context' }
CPActivateProcessDeploymentWorkUnit class >> serviceClass [ ^ CPBpmService ]

{ #category : 'instance creation' }
CPActivateProcessDeploymentWorkUnit class >> processDeployment: aCPProcessDeployment [
	^ self new processDeployment: aCPProcessDeployment; yourself
]

{ #category : 'accessing' }
CPActivateProcessDeploymentWorkUnit >> processDeployment [ ^ processDeployment ]

{ #category : 'accessing' }
CPActivateProcessDeploymentWorkUnit >> processDeployment: aCPProcessDeployment [ processDeployment := aCPProcessDeployment ]

{ #category : 'running' }
CPActivateProcessDeploymentWorkUnit >> executeInContext: aCRWorkUnitExecutionContext [
	^ aCRWorkUnitExecutionContext service activateProcessDeploymentWorkUnit: self
]
