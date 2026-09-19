Class {
	#name : 'CPBPMNLoopExamples',
	#superclass : 'Object',
	#category : 'BVC-BPM-Examples',
	#package : 'BVC-BPM-Examples'
}

{ #category : 'examples - loops' }
CPBPMNLoopExamples >> standardLoopActivity [
	<gtExample>
	| task expression loop |
	task := CPServiceTask identifier: #retryOperation.
	expression := (CPFormalExpression identifier: #retryWhileNeeded)
		body: 'retryNeeded';
		yourself.
	loop := (CPStandardLoopCharacteristics identifier: #retryLoop)
		testBefore: true;
		loopMaximum: 3;
		loopCondition: expression;
		yourself.
	task loopCharacteristics: loop.
	self assert: task loopCharacteristics equals: loop.
	self assert: loop testBefore.
	self assert: loop loopMaximum equals: 3.
	^ task
]

{ #category : 'examples - loops' }
CPBPMNLoopExamples >> multiInstanceActivity [
	<gtExample>
	| task cardinality completion loop |
	task := CPServiceTask identifier: #processJobs.
	cardinality := (CPFormalExpression identifier: #jobCount)
		body: 'jobs size';
		yourself.
	completion := (CPFormalExpression identifier: #allRequiredJobsComplete)
		body: 'numberOfCompletedInstances >= requiredJobs';
		yourself.
	loop := (CPMultiInstanceLoopCharacteristics identifier: #jobInstances)
		loopCardinality: cardinality;
		completionCondition: completion;
		isSequential: false;
		yourself.
	task loopCharacteristics: loop.
	self assert: loop behavior equals: 'All'.
	self assert: loop isSequential not.
	self assert: task loopCharacteristics equals: loop.
	^ task
]
