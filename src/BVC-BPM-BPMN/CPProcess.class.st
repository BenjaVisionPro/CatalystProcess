Class {
	#name : 'CPProcess',
	#superclass : 'CFLabelledObject',
	#instVars : [
		'flowElements',
		'diagram'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'initialization' }
CPProcess >> initialize [
	super initialize.
	flowElements := OrderedCollection new
]

{ #category : 'accessing' }
CPProcess >> flowElements [
	^ flowElements
]

{ #category : 'accessing' }
CPProcess >> flowElements: aCollection [
	flowElements copy do: [ :each | self removeFlowElement: each ].
	aCollection do: [ :each | self addFlowElement: each ]
]

{ #category : 'adding' }
CPProcess >> addFlowElement: aFlowElement [
	(flowElements includes: aFlowElement) ifFalse: [
		flowElements add: aFlowElement.
		aFlowElement container: self ]
]

{ #category : 'removing' }
CPProcess >> removeFlowElement: aFlowElement [
	(flowElements includes: aFlowElement) ifFalse: [ ^ self ].
	aFlowElement prepareForRemovalFrom: self.
	flowElements remove: aFlowElement.
	aFlowElement container: nil
]

{ #category : 'accessing' }
CPProcess >> diagram [
	^ diagram
]

{ #category : 'accessing' }
CPProcess >> diagram: aDiagram [
	diagram := aDiagram.
	diagram ifNotNil: [ :aProcessDiagram | aProcessDiagram modelElement: self ]
]

{ #category : 'descriptions' }
CPProcess >> flowElementsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #flowElements;
		classes: { CPFlowElement };
		reference: self labelDescription;
		label: 'Flow elements';
		priority: 100;
		group: 'Relations';
		yourself
]

{ #category : 'descriptions' }
CPProcess >> diagramDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #diagram;
		classes: { CPDiagram };
		label: 'Diagram';
		priority: 110;
		group: 'Diagram';
		yourself
]

{ #category : 'validation' }
CPProcess >> validationResult [
	^ CPProcessValidator new validateProcess: self
]
