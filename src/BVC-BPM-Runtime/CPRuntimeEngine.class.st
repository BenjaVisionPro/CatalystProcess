Class {
	#name : 'CPRuntimeEngine',
	#superclass : 'Object',
	#category : 'BVC-BPM-Runtime',
	#package : 'BVC-BPM-Runtime'
}

{ #category : 'runtime' }
CPRuntimeEngine >> startProcessFromDeployment: aDeployment startedBy: aUser input: aDictionary [
	| instance token startActivity |
	instance := CPProcessInstance new
		deployment: aDeployment;
		tenant: aDeployment tenant;
		label: aDeployment label;
		startedBy: aUser;
		startedAt: DateAndTime now;
		state: #running;
		yourself.
	aDictionary ifNotNil: [ aDictionary keysAndValuesDo: [ :key :value | instance variableAt: key put: value ] ].
	token := CPExecutionToken new
		processInstance: instance;
		currentNode: aDeployment compiledDefinition startNode;
		yourself.
	instance tokens add: token.
	self appendAuditType: #processStarted process: instance subject: instance actor: aUser payload: Dictionary new.
	startActivity := self enterNode: token currentNode for: instance token: token.
	startActivity complete.
	self advanceFromActivity: startActivity.
	^ instance
]

{ #category : 'runtime' }
CPRuntimeEngine >> claimWorkItem: aWorkItem by: aUser [
	aWorkItem claimBy: aUser.
	self appendAuditType: #workItemClaimed process: aWorkItem processInstance subject: aWorkItem actor: aUser payload: Dictionary new.
	^ aWorkItem
]

{ #category : 'runtime' }
CPRuntimeEngine >> completeWorkItem: aWorkItem by: aUser withOutput: aDictionary [
	aWorkItem claimedBy ifNil: [ self claimWorkItem: aWorkItem by: aUser ].
	aWorkItem completeWith: aDictionary.
	self appendAuditType: #workItemCompleted process: aWorkItem processInstance subject: aWorkItem actor: aUser payload: aWorkItem outputValues.
	aWorkItem activityInstance complete.
	self appendAuditType: #activityCompleted process: aWorkItem processInstance subject: aWorkItem activityInstance actor: aUser payload: Dictionary new.
	self advanceFromActivity: aWorkItem activityInstance.
	^ aWorkItem
]

{ #category : 'runtime' }
CPRuntimeEngine >> cancelProcess: aProcessInstance by: aUser reason: aReason [
	aProcessInstance state: #cancelled.
	aProcessInstance cancelledAt: DateAndTime now.
	self appendAuditType: #processCancelled process: aProcessInstance subject: aProcessInstance actor: aUser payload: (Dictionary new at: #reason put: aReason; yourself).
	^ aProcessInstance
]

{ #category : 'runtime' }
CPRuntimeEngine >> advanceProcessInstance: aProcessInstance [
	aProcessInstance activeWorkItems isEmpty ifTrue: [ ^ aProcessInstance ].
	^ aProcessInstance
]

{ #category : 'private' }
CPRuntimeEngine >> enterNode: aNodeDefinition for: aProcessInstance token: aToken [
	| activity |
	activity := (self activityClassFor: aNodeDefinition) new
		processInstance: aProcessInstance;
		nodeDefinition: aNodeDefinition;
		token: aToken;
		yourself.
	activity start.
	aProcessInstance activityInstances add: activity.
	self appendAuditType: #activityStarted process: aProcessInstance subject: activity actor: nil payload: Dictionary new.
	aNodeDefinition isUserTask ifTrue: [ self createWorkItemFor: activity ].
	aNodeDefinition isServiceTask ifTrue: [ self requestAutomationFor: activity ].
	aNodeDefinition isEndNode ifTrue: [
		activity complete.
		aProcessInstance state: #completed.
		aProcessInstance completedAt: DateAndTime now.
		self appendAuditType: #processCompleted process: aProcessInstance subject: aProcessInstance actor: nil payload: Dictionary new ].
	^ activity
]

{ #category : 'private' }
CPRuntimeEngine >> activityClassFor: aNodeDefinition [
	aNodeDefinition isUserTask ifTrue: [ ^ CPUserTaskInstance ].
	aNodeDefinition isServiceTask ifTrue: [ ^ CPServiceTaskInstance ].
	aNodeDefinition isGateway ifTrue: [ ^ CPGatewayInstance ].
	(aNodeDefinition isStartNode or: [ aNodeDefinition isEndNode ]) ifTrue: [ ^ CPEventInstance ].
	^ CPActivityInstance
]

{ #category : 'private' }
CPRuntimeEngine >> createWorkItemFor: anActivityInstance [
	| workItem |
	workItem := CPWorkItem new
		label: anActivityInstance nodeDefinition label;
		tenant: anActivityInstance processInstance tenant;
		processInstance: anActivityInstance processInstance;
		activityInstance: anActivityInstance;
		yourself.
	anActivityInstance processInstance workItems add: workItem.
	self appendAuditType: #workItemCreated process: anActivityInstance processInstance subject: workItem actor: nil payload: Dictionary new.
	^ workItem
]

{ #category : 'private' }
CPRuntimeEngine >> requestAutomationFor: anActivityInstance [
	self appendAuditType: #automationRequested process: anActivityInstance processInstance subject: anActivityInstance actor: nil payload: Dictionary new.
	^ anActivityInstance
]

{ #category : 'private' }
CPRuntimeEngine >> advanceFromActivity: anActivityInstance [
	| compiled transitions process |
	process := anActivityInstance processInstance.
	compiled := process deployment compiledDefinition.
	transitions := compiled outgoingTransitionsFrom: anActivityInstance nodeDefinition.
	transitions do: [ :transition |
		| nextActivity |
		self appendAuditType: #transitionTaken process: process subject: transition actor: nil payload: Dictionary new.
		anActivityInstance token currentNode: transition targetNode.
		nextActivity := self enterNode: transition targetNode for: process token: anActivityInstance token.
		(nextActivity nodeDefinition isUserTask or: [ nextActivity nodeDefinition isServiceTask or: [ nextActivity nodeDefinition isEndNode ] ]) ifFalse: [
			nextActivity complete.
			self advanceFromActivity: nextActivity ] ]
]

{ #category : 'private' }
CPRuntimeEngine >> appendAuditType: aSymbol process: aProcessInstance subject: aSubject actor: anActor payload: aDictionary [
	| event |
	event := CPAuditEvent new
		tenant: aProcessInstance tenant;
		processInstance: aProcessInstance;
		eventType: aSymbol;
		subject: aSubject;
		actor: anActor;
		payload: aDictionary;
		yourself.
	aProcessInstance appendAuditEvent: event.
	^ event
]

