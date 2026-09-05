Class {
	#name : 'CPSubProcessTypeSelection',
	#superclass : 'CPFlowNodeTypeSelection',
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'type protocol' }
CPSubProcessTypeSelection >> typeClasses [
	^ CPSubProcess subProcessTypes
]

{ #category : 'type protocol' }
CPSubProcessTypeSelection >> typeDescriptionLabel [
	^ 'Sub-process type'
]

{ #category : 'type protocol' }
CPSubProcessTypeSelection >> typeLabelFor: aClass [
	^ aClass subProcessTypeLabel
]

{ #category : 'type protocol' }
CPSubProcessTypeSelection >> typeIconFor: aClass [
	^ aClass subProcessTypeIcon
]
