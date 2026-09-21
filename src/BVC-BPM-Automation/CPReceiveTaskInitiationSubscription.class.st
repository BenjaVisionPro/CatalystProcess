Class {
	#name : 'CPReceiveTaskInitiationSubscription',
	#superclass : 'CPEventBasedGatewayInitiationSubscription',
	#instVars : [ 'receiveTask' ],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'accessing' }
CPReceiveTaskInitiationSubscription >> receiveTask [
	^ receiveTask
]

{ #category : 'accessing' }
CPReceiveTaskInitiationSubscription >> receiveTask: aReceiveTask [
	receiveTask := aReceiveTask
]

{ #category : 'process initiation' }
CPReceiveTaskInitiationSubscription >> instantiateUsingService: aBpmService occurrence: anOccurrence [
	^ aBpmService
		instantiateReceiveTask: receiveTask
		fromDeployment: self processDeployment
		occurrence: anOccurrence
]
