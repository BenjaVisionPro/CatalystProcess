Class {
	#name : 'CPTask',
	#superclass : 'CPActivity',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'task type' }
CPTask class >> taskTypes [
	^ {
		CPUserTask.
		CPServiceTask.
		CPSendTask.
		CPReceiveTask.
		CPManualTask.
		CPScriptTask.
		CPBusinessRuleTask
	}
]

{ #category : 'task type' }
CPTask >> isTask [
	^ true
]
