Class {
	#name : 'CPConditionalEventSubProcessSubscription',
	#superclass : 'CPConditionalSubscription',
	#instVars : [ 'scope', 'eventSubProcess', 'startEvent' ],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}
{ #category : 'accessing' }
CPConditionalEventSubProcessSubscription >> scope [ ^ scope ]
{ #category : 'accessing' }
CPConditionalEventSubProcessSubscription >> scope: anExecutionScope [ scope := anExecutionScope ]
{ #category : 'accessing' }
CPConditionalEventSubProcessSubscription >> eventSubProcess [ ^ eventSubProcess ]
{ #category : 'accessing' }
CPConditionalEventSubProcessSubscription >> eventSubProcess: aSubProcess [ eventSubProcess := aSubProcess ]
{ #category : 'accessing' }
CPConditionalEventSubProcessSubscription >> startEvent [ ^ startEvent ]
{ #category : 'accessing' }
CPConditionalEventSubProcessSubscription >> startEvent: aStartEvent [ startEvent := aStartEvent ]
{ #category : 'conditional events' }
CPConditionalEventSubProcessSubscription >> triggerInScope: anExecutionScope [
	^ anExecutionScope acceptConditionalEventSubProcessSubscription: self
]

{ #category : 'accessing' }
CPConditionalEventSubProcessSubscription >> executionScope [ ^ scope ]

{ #category : 'conditional events' }
CPConditionalEventSubProcessSubscription >> reevaluateInScope: anExecutionScope [ ^ anExecutionScope evaluateConditionalEventSubProcessSubscription: self ]
