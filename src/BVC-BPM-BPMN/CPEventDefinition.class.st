"I represent the abstract BPMN EventDefinition carried by catch/throw Events. Concrete subclasses identify one BPMN trigger/result family."
Class {
	#name : 'CPEventDefinition',
	#superclass : 'CFIdentifiableObject',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'event type' }
CPEventDefinition class >> eventTypeLabel [
	^ self subclassResponsibility
]

{ #category : 'event type' }
CPEventDefinition class >> eventTypeIcon [
	^ self subclassResponsibility
]

{ #category : 'event type' }
CPEventDefinition >> eventTypeLabel [
	^ self class eventTypeLabel
]

{ #category : 'descriptions' }
CPEventDefinition >> eventTypeLabelDescription [
	<magritteDescription>
	^ MAStringDescription new
		accessor: #eventTypeLabel;
		label: 'Type';
		priority: 20;
		beReadOnly;
		yourself
]
