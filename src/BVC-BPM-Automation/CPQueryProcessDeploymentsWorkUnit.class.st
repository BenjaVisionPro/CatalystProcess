Class {
	#name : 'CPQueryProcessDeploymentsWorkUnit',
	#superclass : 'CRWorkUnit',
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'service context' }
CPQueryProcessDeploymentsWorkUnit class >> serviceClass [
	^ CPBpmService
]

{ #category : 'running' }
CPQueryProcessDeploymentsWorkUnit >> executeInContext: aCRWorkUnitExecutionContext [
	^ aCRWorkUnitExecutionContext service queryProcessDeploymentsWorkUnit: self
]
