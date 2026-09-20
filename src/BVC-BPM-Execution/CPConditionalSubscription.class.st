Class {
	#name : 'CPConditionalSubscription',
	#superclass : 'CFIdentifiableObject',
	#instVars : [ 'waitingExecution', 'condition', 'triggered', 'cancelled' ],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'initialization' }
CPConditionalSubscription >> initialize [
	super initialize.
	triggered := false.
	cancelled := false
]

{ #category : 'accessing' }
CPConditionalSubscription >> waitingExecution [ ^ waitingExecution ]
{ #category : 'accessing' }
CPConditionalSubscription >> waitingExecution: anExecution [ waitingExecution := anExecution ]
{ #category : 'accessing' }
CPConditionalSubscription >> condition [ ^ condition ]
{ #category : 'accessing' }
CPConditionalSubscription >> condition: anExpression [ condition := anExpression ]

{ #category : 'testing' }
CPConditionalSubscription >> isWaiting [ ^ triggered not and: [ cancelled not ] ]
{ #category : 'testing' }
CPConditionalSubscription >> isTriggered [ ^ triggered ]
{ #category : 'testing' }
CPConditionalSubscription >> isCancelled [ ^ cancelled ]

{ #category : 'conditional events' }
CPConditionalSubscription >> trigger [
	self isWaiting ifFalse: [ self error: 'A Conditional subscription can be triggered only once.' ].
	triggered := true.
	^ self
]

{ #category : 'lifecycle' }
CPConditionalSubscription >> cancel [
	self isWaiting ifFalse: [ self error: 'Only a waiting Conditional subscription can be cancelled.' ].
	cancelled := true.
	^ self
]
