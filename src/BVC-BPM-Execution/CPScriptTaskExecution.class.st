Class {
	#name : 'CPScriptTaskExecution',
	#superclass : 'CPActivityExecution',
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'looping' }
CPScriptTaskExecution >> standardLoopIterationDidBegin: anIteration [
	super standardLoopIterationDidBegin: anIteration.
	scope executeStandardLoopScriptTaskIteration: anIteration.
	^ anIteration
]

{ #category : 'multi-instance' }
CPScriptTaskExecution >> multiInstanceActivityExecutionDidBegin: anInstance [
	super multiInstanceActivityExecutionDidBegin: anInstance.
	scope executeMultiInstanceScriptTaskExecution: anInstance.
	^ anInstance
]
