Class {
	#name : 'CPCompensationRecord',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'activityExecution',
		'boundaryEvent'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'accessing' }
CPCompensationRecord >> activityExecution [ ^ activityExecution ]

{ #category : 'accessing' }
CPCompensationRecord >> activityExecution: anActivityExecution [ activityExecution := anActivityExecution ]

{ #category : 'accessing' }
CPCompensationRecord >> boundaryEvent [ ^ boundaryEvent ]

{ #category : 'accessing' }
CPCompensationRecord >> boundaryEvent: aBoundaryEvent [ boundaryEvent := aBoundaryEvent ]

{ #category : 'testing' }
CPCompensationRecord >> isAvailable [
	^ activityExecution isCompleted
]
