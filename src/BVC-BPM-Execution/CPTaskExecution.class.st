Class {
	#name : 'CPTaskExecution',
	#superclass : 'CPActivityExecution',
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'multi-instance' }
CPTaskExecution >> multiInstanceActivityExecutionDidBegin: anInstance [
	super multiInstanceActivityExecutionDidBegin: anInstance.
	scope completeMultiInstanceAbstractTaskExecution: anInstance.
	^ anInstance
]

{ #category : 'looping' }
CPTaskExecution >> standardLoopIterationDidBegin: anIteration [
	super standardLoopIterationDidBegin: anIteration.
	scope completeStandardLoopIteration: anIteration of: self.
	^ anIteration
]
