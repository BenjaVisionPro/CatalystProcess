Class {
	#name : 'CPSequenceFlow',
	#superclass : 'CPFlowElement',
	#instVars : [
		'sourceRef',
		'targetRef',
		'conditionExpression'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'accessing' }
CPSequenceFlow >> sourceRef [
	^ sourceRef
]

{ #category : 'accessing' }
CPSequenceFlow >> sourceRef: aFlowNode [
	sourceRef == aFlowNode ifTrue: [ ^ self ].
	sourceRef ifNotNil: [ :aPreviousSource | aPreviousSource removeOutgoing: self ].
	sourceRef := aFlowNode.
	sourceRef ifNotNil: [ :aSource | aSource addOutgoing: self ]
]

{ #category : 'accessing' }
CPSequenceFlow >> targetRef [
	^ targetRef
]

{ #category : 'accessing' }
CPSequenceFlow >> targetRef: aFlowNode [
	targetRef == aFlowNode ifTrue: [ ^ self ].
	targetRef ifNotNil: [ :aPreviousTarget | aPreviousTarget removeIncoming: self ].
	targetRef := aFlowNode.
	targetRef ifNotNil: [ :aTarget | aTarget addIncoming: self ]
]

{ #category : 'accessing' }
CPSequenceFlow >> conditionExpression [
	^ conditionExpression
]

{ #category : 'accessing' }
CPSequenceFlow >> conditionExpression: anExpression [
	conditionExpression := anExpression
]

{ #category : 'descriptions' }
CPSequenceFlow >> conditionExpressionDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #conditionExpression;
		classes: { CPExpression };
		reference: CPExpression new identifierDescription;
		label: 'Condition';
		priority: 100;
		group: 'Relations';
		yourself
]

{ #category : 'descriptions' }
CPSequenceFlow >> sourceRefDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #sourceRef;
		classes: { CPFlowNode };
		reference: self labelDescription;
		label: 'Source';
		priority: 110;
		group: 'Relations';
		beRequired;
		yourself
]

{ #category : 'descriptions' }
CPSequenceFlow >> targetRefDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #targetRef;
		classes: { CPFlowNode };
		reference: self labelDescription;
		label: 'Target';
		priority: 120;
		group: 'Relations';
		beRequired;
		yourself
]

{ #category : 'private - containment' }
CPSequenceFlow >> prepareForRemovalFrom: aContainer [
	self sourceRef: nil.
	self targetRef: nil
]

{ #category : 'testing' }
CPSequenceFlow >> isSequenceFlow [
	^ true
]

{ #category : 'accessing' }
CPSequenceFlow class >> defaultIcon [
	^ #sequenceFlow
]
