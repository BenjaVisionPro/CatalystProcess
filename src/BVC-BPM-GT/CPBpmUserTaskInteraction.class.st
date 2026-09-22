"I bind one authoritative User Task work item to a Foundation memento. I keep editing local to Foundation until submit; submission commits the memento and sends the resulting model through the BPM application command boundary."
Class {
	#name : 'CPBpmUserTaskInteraction',
	#superclass : 'Object',
	#instVars : [
		'application',
		'workItem',
		'model',
		'memento',
		'viewModel'
	],
	#category : 'BVC-BPM-GT-Workspace',
	#package : 'BVC-BPM-GT',
	#tag : 'Workspace'
}

{ #category : 'instance creation' }
CPBpmUserTaskInteraction class >> application: aCPBpmApplication workItem: aCPUserTaskWorkItem model: anObject [
	| memento |
	memento := CFMaMemento model: anObject.
	^ self new
		application: aCPBpmApplication;
		workItem: aCPUserTaskWorkItem;
		model: anObject;
		memento: memento;
		viewModel: (CFMaViewModel forObject: anObject memento: memento);
		yourself
]

{ #category : 'accessing' }
CPBpmUserTaskInteraction >> application [ ^ application ]

{ #category : 'accessing' }
CPBpmUserTaskInteraction >> application: anApplication [ application := anApplication ]

{ #category : 'accessing' }
CPBpmUserTaskInteraction >> workItem [ ^ workItem ]

{ #category : 'accessing' }
CPBpmUserTaskInteraction >> workItem: aWorkItem [ workItem := aWorkItem ]

{ #category : 'accessing' }
CPBpmUserTaskInteraction >> model [ ^ model ]

{ #category : 'accessing' }
CPBpmUserTaskInteraction >> model: anObject [ model := anObject ]

{ #category : 'accessing' }
CPBpmUserTaskInteraction >> memento [ ^ memento ]

{ #category : 'accessing' }
CPBpmUserTaskInteraction >> memento: aMemento [ memento := aMemento ]

{ #category : 'accessing' }
CPBpmUserTaskInteraction >> viewModel [ ^ viewModel ]

{ #category : 'accessing' }
CPBpmUserTaskInteraction >> viewModel: aViewModel [ viewModel := aViewModel ]

{ #category : 'presentation' }
CPBpmUserTaskInteraction >> element [
	^ viewModel preparedElementForMemento: memento
]

{ #category : 'commands' }
CPBpmUserTaskInteraction >> submit [
	memento commit.
	application completeUserTaskWorkItem: workItem outputValue: model.
	^ model
]
