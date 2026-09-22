"I am the first GT administrative workspace over the BPM application boundary. My views are deliberately thin: they present the authoritative collections supplied by CPBpmApplication. State-changing interactions are application commands, not direct Process mutations."
Class {
	#name : 'CPBpmWorkspace',
	#superclass : 'Object',
	#instVars : [
		'application'
	],
	#category : 'BVC-BPM-GT-Workspace',
	#package : 'BVC-BPM-GT',
	#tag : 'Workspace'
}

{ #category : 'instance creation' }
CPBpmWorkspace class >> application: aCPBpmApplication [
	^ self new application: aCPBpmApplication; yourself
]

{ #category : 'accessing' }
CPBpmWorkspace >> application [ ^ application ]

{ #category : 'accessing' }
CPBpmWorkspace >> application: aCPBpmApplication [ application := aCPBpmApplication ]

{ #category : 'private' }
CPBpmWorkspace >> requiredApplication [
	application ifNil: [ self error: 'A BPM application is required.' ].
	^ application
]

{ #category : 'commands' }
CPBpmWorkspace >> startProcessDeployment: aCPProcessDeployment [
	^ self requiredApplication startProcessDeployment: aCPProcessDeployment
]

{ #category : 'commands' }
CPBpmWorkspace >> claimUserTaskWorkItem: aCPUserTaskWorkItem [
	^ self requiredApplication claimUserTaskWorkItem: aCPUserTaskWorkItem
]


{ #category : 'commands' }
CPBpmWorkspace >> completeUserTaskWorkItem: aCPUserTaskWorkItem [
	^ self requiredApplication completeUserTaskWorkItem: aCPUserTaskWorkItem
]

{ #category : 'gt - views' }
CPBpmWorkspace >> gtStartableProcessesFor: aView [
	<gtView>
	^ aView list
		title: 'Startable Processes';
		priority: 10;
		items: [ self requiredApplication startableProcessDeployments ]
]

{ #category : 'gt - views' }
CPBpmWorkspace >> gtInboxFor: aView [
	<gtView>
	^ aView list
		title: 'Inbox';
		priority: 20;
		items: [ self requiredApplication assignedUserTaskWorkItems ]
]

{ #category : 'gt - views' }
CPBpmWorkspace >> gtClaimableWorkFor: aView [
	<gtView>
	^ aView list
		title: 'Claimable Work';
		priority: 30;
		items: [ self requiredApplication claimableUserTaskWorkItems ]
]


{ #category : 'user task interaction' }
CPBpmWorkspace >> interactionModelForUserTaskWorkItem: aCPUserTaskWorkItem [
	| task inputs model |
	aCPUserTaskWorkItem ifNil: [ self error: 'A User Task work item is required.' ].
	task := aCPUserTaskWorkItem userTask.
	task ifNil: [ self error: 'A User Task work item requires its User Task.' ].
	inputs := task ioSpecification
		ifNil: [ #() ]
		ifNotNil: [ :specification | specification dataInputs ].
	inputs size = 1 ifFalse: [
		self error: 'A Foundation User Task interaction requires exactly one DataInput.' ].
	model := aCPUserTaskWorkItem activityExecution itemValueFor: inputs first.
	model ifNil: [ self error: 'The User Task interaction DataInput has no value.' ].
	^ model
]

{ #category : 'user task interaction' }
CPBpmWorkspace >> foundationInteractionForUserTaskWorkItem: aCPUserTaskWorkItem [
	| model memento viewModel |
	model := self interactionModelForUserTaskWorkItem: aCPUserTaskWorkItem.
	memento := CFMaMemento model: model.
	viewModel := CFMaViewModel forObject: model memento: memento.
	^ viewModel preparedElementForMemento: memento
]


{ #category : 'user task interaction' }
CPBpmWorkspace >> userTaskInteractionForUserTaskWorkItem: aCPUserTaskWorkItem [
	^ CPBpmUserTaskInteraction
		application: self requiredApplication
		workItem: aCPUserTaskWorkItem
		model: (self interactionModelForUserTaskWorkItem: aCPUserTaskWorkItem)
]
