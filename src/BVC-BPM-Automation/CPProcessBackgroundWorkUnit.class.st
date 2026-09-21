Class {
	#name : 'CPProcessBackgroundWorkUnit',
	#superclass : 'CRWorkUnit',
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'service context' }
CPProcessBackgroundWorkUnit class >> serviceClass [
	^ CPBpmService
]

{ #category : 'running' }
CPProcessBackgroundWorkUnit >> executeInContext: aCRWorkUnitExecutionContext [
	^ aCRWorkUnitExecutionContext service processBackgroundWorkUnit: self
]
