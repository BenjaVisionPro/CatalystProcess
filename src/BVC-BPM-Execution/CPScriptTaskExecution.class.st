Class {
	#name : 'CPScriptTaskExecution',
	#superclass : 'CPActivityExecution',
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'multi-instance' }
CPScriptTaskExecution >> multiInstanceActivityExecutionDidBegin: anInstance [
	super multiInstanceActivityExecutionDidBegin: anInstance.
	scope executeMultiInstanceScriptTaskExecution: anInstance.
	^ anInstance
]
