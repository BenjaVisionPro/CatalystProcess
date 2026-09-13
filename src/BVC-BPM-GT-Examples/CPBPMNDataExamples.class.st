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
		label: 'Order [approved]';
		dataObjectRef: dataObject;
		dataState: (CPDataState new label: 'approved');
		yourself.
	self assert: reference itemSubjectRef == dataObject itemSubjectRef.
	self assert: reference structureRef == dataObject structureRef.
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
