Class {
	#name : 'CPTaskTypeSelection',
	#superclass : 'CPFlowNodeTypeSelection',
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'type protocol' }
CPTaskTypeSelection >> typeClasses [
	^ CPTask taskTypes
]

{ #category : 'type protocol' }
CPTaskTypeSelection >> typeDescriptionLabel [
	^ 'Task type'
]

{ #category : 'type protocol' }
CPTaskTypeSelection >> typeLabelFor: aClass [
	^ aClass taskTypeLabel
]

{ #category : 'type protocol' }
CPTaskTypeSelection >> typeIconFor: aClass [
	^ aClass taskTypeIcon
]
