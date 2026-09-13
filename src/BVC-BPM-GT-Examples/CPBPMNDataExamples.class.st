Class {
	#name : 'CPBPMNDataExamples',
	#superclass : 'Object',
	#category : 'BVC-BPM-GT-Examples',
	#package : 'BVC-BPM-GT-Examples'
}

{ #category : 'examples - data' }
CPBPMNDataExamples >> dataObjectUsesExternalMagritteStructure [
	<gtExample>
	| structure itemDefinition dataObject |
	structure := CPProcess new label: 'Application object'.
	itemDefinition := CPItemDefinition forStructure: structure.
	dataObject := CPDataObject new
		label: 'Order';
		itemSubjectRef: itemDefinition;
		yourself.
	self assert: dataObject structureRef == structure.
	self assert: itemDefinition structureRef == structure.
	^ dataObject
]

{ #category : 'examples - data' }
CPBPMNDataExamples >> dataObjectReferenceSharesUnderlyingStructure [
	<gtExample>
	| dataObject reference |
	dataObject := self dataObjectUsesExternalMagritteStructure.
	reference := CPDataObjectReference new
		dataObjectRef: dataObject;
		dataState: (CPDataState new label: 'approved');
		yourself.
	self assert: reference itemSubjectRef == dataObject itemSubjectRef.
	self assert: reference structureRef == dataObject structureRef.
	self assert: reference label equals: dataObject label.
	reference label: 'Renamed order'.
	self assert: dataObject label equals: 'Renamed order'.
	^ reference
]

{ #category : 'examples - data' }
CPBPMNDataExamples >> inputOutputSpecificationStartsValid [
	<gtExample>
	| specification |
	specification := CPInputOutputSpecification new.
	self assert: specification inputSets size = 1.
	self assert: specification outputSets size = 1.
	^ specification
]

{ #category : 'examples - data' }
CPBPMNDataExamples >> dataAssociationConnectsItemAwareElements [
	<gtExample>
	| dataObject dataInput association |
	dataObject := self dataObjectUsesExternalMagritteStructure.
	dataInput := CPDataInput new
		label: 'Order input';
		itemSubjectRef: dataObject itemSubjectRef;
		yourself.
	association := CPDataInputAssociation new
		sourceRefs: { dataObject };
		targetRef: dataInput;
		yourself.
	self assert: association sourceRefs first == dataObject.
	self assert: association targetRef == dataInput.
	self assert: association sourceRefs first structureRef == association targetRef structureRef.
	^ association
]


{ #category : 'examples - events' }
CPBPMNDataExamples >> catchEventOwnsOutputDataContract [
	<gtExample>
	| event output association |
	event := CPMessageStartEvent new.
	output := CPDataOutput new label: 'Message payload'; yourself.
	association := CPDataOutputAssociation new
		sourceRefs: { output };
		targetRef: (CPProperty new label: 'Received payload'; yourself);
		yourself.
	event
		dataOutputs: { output };
		outputSet: (CPOutputSet new dataOutputRefs: { output }; yourself);
		dataOutputAssociations: { association }.
	self assert: event isCatchEvent.
	self assert: (event isThrowEvent not).
	self assert: event dataOutputs first == output.
	self assert: event dataOutputAssociations first == association.
	^ event
]

{ #category : 'examples - events' }
CPBPMNDataExamples >> throwEventOwnsInputDataContract [
	<gtExample>
	| event input association |
	event := CPMessageEndEvent new.
	input := CPDataInput new label: 'Message payload'; yourself.
	association := CPDataInputAssociation new
		sourceRefs: { (CPProperty new label: 'Payload'; yourself) };
		targetRef: input;
		yourself.
	event
		dataInputs: { input };
		inputSet: (CPInputSet new dataInputRefs: { input }; yourself);
		dataInputAssociations: { association }.
	self assert: event isThrowEvent.
	self assert: (event isCatchEvent not).
	self assert: event dataInputs first == input.
	self assert: event dataInputAssociations first == association.
	^ event
]

{ #category : 'examples - events' }
CPBPMNDataExamples >> intermediateEventsHaveExplicitCatchOrThrowSemantics [
	<gtExample>
	| catch throw |
	catch := CPMessageCatchIntermediateEvent new.
	throw := CPMessageThrowIntermediateEvent new.
	self assert: catch isIntermediateEvent.
	self assert: catch isCatchEvent.
	self assert: (catch isThrowEvent not).
	self assert: throw isIntermediateEvent.
	self assert: throw isThrowEvent.
	self assert: (throw isCatchEvent not).
	self assert: (CPEvent intermediateEventTypes includes: CPSignalThrowIntermediateEvent).
	self assert: (CPEvent intermediateEventTypes includes: CPLinkThrowIntermediateEvent).
	^ { catch. throw }
]

{ #category : 'examples - events' }
CPBPMNDataExamples >> boundaryEventIsCatchEventWithoutIntermediateSuperclass [
	<gtExample>
	| event |
	event := CPBoundaryEvent new.
	self assert: event isBoundaryEvent.
	self assert: event isIntermediateEvent.
	self assert: event isCatchEvent.
	self assert: (event isThrowEvent not).
	^ event
]


{ #category : 'examples - data' }
CPBPMNDataExamples >> dataReferenceAndAssociationAreValidDiagramSubjects [
	<gtExample>
	| dataObject reference shape association edge |
	dataObject := CPDataObject new label: 'Order'; yourself.
	reference := CPDataObjectReference new dataObjectRef: dataObject; yourself.
	shape := CPShape new modelElement: reference; bounds: (100 @ 100 extent: 44 @ 54); yourself.
	association := CPDataInputAssociation new.
	edge := CPEdge new modelElement: association; yourself.

	shape modelElementDescription validate: reference.
	edge modelElementDescription validate: association.

	self assert: shape modelElement == reference.
	self assert: edge modelElement == association.
	^ shape
]
