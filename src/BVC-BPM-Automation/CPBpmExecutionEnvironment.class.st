"I am the Process execution environment installed by CPBpmService for ordinary application execution.

I deliberately provide only behavior that has a production meaning without an operational-release binding. Human User Task distribution needs no external implementation: the durable CPUserTaskWorkItem is already owned by Process and is discovered through CPBpmService queries.

Operation, callable, expression, resource, script, business-rule, assignment and Timer resolution remain explicit CPExecutionEnvironment responsibilities. They are not guessed here from identifiers or implementationRef values. As operational-release bindings are introduced, those responsibilities can be implemented against that authoritative configuration."
Class {
	#name : 'CPBpmExecutionEnvironment',
	#superclass : 'CPExecutionEnvironment',
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'execution' }
CPBpmExecutionEnvironment >> distributeUserTaskWorkItem: aWorkItem in: anExecutionScope [
	^ aWorkItem
]

{ #category : 'resolution' }
CPBpmExecutionEnvironment >> resolveOperation: anOperation in: anExecutionScope [
	| deployment release |
	deployment := anExecutionScope processExecution deployment.
	deployment ifNil: [ self error: 'Operation resolution requires a Process deployment.' ].
	release := deployment operationalRelease.
	release ifNil: [ self error: 'Operation resolution requires an Operational Release.' ].
	^ release implementationForOperation: anOperation
]
