Class {
	#name : 'CPQueryProcessExecutionsWorkUnit',
	#superclass : 'CRWorkUnit',
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'service context' }
CPQueryProcessExecutionsWorkUnit class >> serviceClass [
	^ CPBpmService
]

{ #category : 'running' }
CPQueryProcessExecutionsWorkUnit >> executeInContext: aCRWorkUnitExecutionContext [
	^ aCRWorkUnitExecutionContext service queryProcessExecutionsWorkUnit: self
]
