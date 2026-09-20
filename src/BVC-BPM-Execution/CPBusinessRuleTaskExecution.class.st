Class {
	#name : 'CPBusinessRuleTaskExecution',
	#superclass : 'CPActivityExecution',
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'looping' }
CPBusinessRuleTaskExecution >> standardLoopIterationDidBegin: anIteration [
	super standardLoopIterationDidBegin: anIteration.
	scope executeStandardLoopBusinessRuleTaskIteration: anIteration.
	^ anIteration
]

{ #category : 'multi-instance' }
CPBusinessRuleTaskExecution >> multiInstanceActivityExecutionDidBegin: anInstance [
	super multiInstanceActivityExecutionDidBegin: anInstance.
	scope executeMultiInstanceBusinessRuleTaskExecution: anInstance.
	^ anInstance
]
