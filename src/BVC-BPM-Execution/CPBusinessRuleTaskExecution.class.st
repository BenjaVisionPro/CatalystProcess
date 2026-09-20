Class {
	#name : 'CPBusinessRuleTaskExecution',
	#superclass : 'CPActivityExecution',
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'multi-instance' }
CPBusinessRuleTaskExecution >> multiInstanceActivityExecutionDidBegin: anInstance [
	super multiInstanceActivityExecutionDidBegin: anInstance.
	scope executeMultiInstanceBusinessRuleTaskExecution: anInstance.
	^ anInstance
]
