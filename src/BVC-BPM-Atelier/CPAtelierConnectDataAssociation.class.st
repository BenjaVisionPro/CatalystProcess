"I stage one BPMN Data Association between a depicted Data Object Reference and an Activity.

For Data -> Activity I create a CPDataInput, add it to the Activity IO specification and InputSet, create a CPDataInputAssociation from the Data Object Reference to that input, and depict the association ending at the Activity shape through CPEdge>>targetElement.

For Activity -> Data I create the corresponding CPDataOutput and CPDataOutputAssociation and use CPEdge>>sourceElement for the visible Activity endpoint."
Class {
	#name : 'CPAtelierConnectDataAssociation',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'dataReference',
		'activity',
		'inputAssociation',
		'processMemento',
		'flowContainerContext',
		'diagramContext'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierConnectDataAssociation class >> dataReference: aReference activity: anActivity inputAssociation: isInput flowContainer: aContainer processMemento: aMemento diagramContext: aDiagramContext [
	^ self new
		dataReference: aReference;
		activity: anActivity;
		inputAssociation: isInput;
		processMemento: aMemento;
		flowContainerContext: (CPProcessFlowContainerContext forContainer: aContainer inRootMemento: aMemento);
		diagramContext: aDiagramContext;
		yourself
]

{ #category : 'assessing' }
CPAtelierConnectDataAssociation >> assess [
	| flowElements activityMemento ioDescription ioSpecification ioMemento dataItem dataItemsDescription currentDataItems setsDescription currentSets set setMemento setRefsDescription currentSetRefs proposedDataItems proposedSetRefs association associationsDescription currentAssociations proposedAssociations dataShape activityShape edge elements proposedElements |
	flowContainerContext ifNil: [ ^ self rejectedBecause: 'The target flow container is not present in staged state.' ].
	flowElements := flowContainerContext stagedFlowElements.
	(flowElements identityIncludes: dataReference) ifFalse: [ ^ self rejectedBecause: 'The Data Object Reference does not belong to the target flow container.' ].
	(flowElements identityIncludes: activity) ifFalse: [ ^ self rejectedBecause: 'The Activity does not belong to the target flow container.' ].
	dataReference isDataObjectReference ifFalse: [ ^ self rejectedBecause: 'A Data Object Reference is required.' ].
	activity isActivity ifFalse: [ ^ self rejectedBecause: 'An Activity is required.' ].

	activityMemento := flowContainerContext childMementoFor: activity.
	ioDescription := activity ioSpecificationDescription.
	ioSpecification := activityMemento readUsing: ioDescription.
	ioSpecification
		ifNil: [ ioSpecification := CPInputOutputSpecification new ]
		ifNotNil: [ ioMemento := activityMemento childMementoFor: ioSpecification inRelation: ioDescription ].

	inputAssociation
		ifTrue: [
			dataItem := CPDataInput new
				label: dataReference label;
				itemSubjectRef: dataReference itemSubjectRef;
				yourself.
			dataItemsDescription := ioSpecification dataInputsDescription.
			setsDescription := ioSpecification inputSetsDescription.
			currentDataItems := ioMemento
				ifNil: [ ioSpecification dataInputs ]
				ifNotNil: [ ioMemento readUsing: dataItemsDescription ].
			currentSets := ioMemento
				ifNil: [ ioSpecification inputSets ]
				ifNotNil: [ ioMemento readUsing: setsDescription ].
			currentSets ifEmpty: [ ^ self rejectedBecause: 'The Activity IO specification requires an InputSet.' ].
			set := currentSets first.
			setRefsDescription := set dataInputRefsDescription.
			setMemento := ioMemento ifNotNil: [ ioMemento childMementoFor: set inRelation: setsDescription ].
			currentSetRefs := setMemento
				ifNil: [ set dataInputRefs ]
				ifNotNil: [ setMemento readUsing: setRefsDescription ].
			association := CPDataInputAssociation new
				sourceRefs: { dataReference };
				targetRef: dataItem;
				yourself.
			associationsDescription := activity dataInputAssociationsDescription.
			currentAssociations := activityMemento readUsing: associationsDescription ]
		ifFalse: [
			dataItem := CPDataOutput new
				label: dataReference label;
				itemSubjectRef: dataReference itemSubjectRef;
				yourself.
			dataItemsDescription := ioSpecification dataOutputsDescription.
			setsDescription := ioSpecification outputSetsDescription.
			currentDataItems := ioMemento
				ifNil: [ ioSpecification dataOutputs ]
				ifNotNil: [ ioMemento readUsing: dataItemsDescription ].
			currentSets := ioMemento
				ifNil: [ ioSpecification outputSets ]
				ifNotNil: [ ioMemento readUsing: setsDescription ].
			currentSets ifEmpty: [ ^ self rejectedBecause: 'The Activity IO specification requires an OutputSet.' ].
			set := currentSets first.
			setRefsDescription := set dataOutputRefsDescription.
			setMemento := ioMemento ifNotNil: [ ioMemento childMementoFor: set inRelation: setsDescription ].
			currentSetRefs := setMemento
				ifNil: [ set dataOutputRefs ]
				ifNotNil: [ setMemento readUsing: setRefsDescription ].
			association := CPDataOutputAssociation new
				sourceRefs: { dataItem };
				targetRef: dataReference;
				yourself.
			associationsDescription := activity dataOutputAssociationsDescription.
			currentAssociations := activityMemento readUsing: associationsDescription ].

	proposedDataItems := currentDataItems asOrderedCollection copy.
	proposedDataItems add: dataItem.
	[ dataItemsDescription validate: proposedDataItems ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].
	proposedSetRefs := currentSetRefs asOrderedCollection copy.
	proposedSetRefs add: dataItem.
	[ setRefsDescription validate: proposedSetRefs ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].
	proposedAssociations := currentAssociations asOrderedCollection copy.
	proposedAssociations add: association.
	[ associationsDescription validate: proposedAssociations ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].
	[ association sourceRefsDescription validate: association sourceRefs.
	  association targetRefDescription validate: association targetRef ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	dataShape := diagramContext shapeForModelElement: dataReference.
	activityShape := diagramContext shapeForModelElement: activity.
	(dataShape isNil or: [ activityShape isNil ]) ifTrue: [ ^ self rejectedBecause: 'Both Data Association endpoints require diagram shapes.' ].
	edge := CPEdge new
		modelElement: association;
		yourself.
	inputAssociation
		ifTrue: [
			edge
				sourceElement: dataShape;
				targetElement: activityShape ]
		ifFalse: [
			edge
				sourceElement: activityShape;
				targetElement: dataShape ].
	edge
		addWaypoint: (diagramContext boundsOf: edge sourceElement) center;
		addWaypoint: (diagramContext boundsOf: edge targetElement) center.
	elements := diagramContext elements.
	proposedElements := elements asOrderedCollection copy.
	proposedElements add: edge.
	[ diagramContext validateElements: proposedElements ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	^ CPAtelierConnectDataAssociationAssessment
		dataReference: dataReference
		activity: activity
		association: association
		dataItem: dataItem
		ioSpecification: ioSpecification
		set: set
		edge: edge
		inputAssociation: inputAssociation
		proposedDataItems: proposedDataItems
		proposedSetRefs: proposedSetRefs
		proposedAssociations: proposedAssociations
		proposedDiagramElements: proposedElements
]

{ #category : 'applying' }
CPAtelierConnectDataAssociation >> applyAssessment: anAssessment [
	| activityMemento ioDescription ioSpecification ioMemento dataItemsDescription setsDescription setMemento setRefsDescription associationsDescription |
	activityMemento := flowContainerContext childMementoFor: activity.
	ioDescription := activity ioSpecificationDescription.
	ioSpecification := activityMemento readUsing: ioDescription.
	ioSpecification ifNil: [
		activityMemento write: anAssessment ioSpecification using: ioDescription.
		ioSpecification := anAssessment ioSpecification ].
	ioMemento := activityMemento childMementoFor: ioSpecification inRelation: ioDescription.

	anAssessment inputAssociation
		ifTrue: [
			dataItemsDescription := ioSpecification dataInputsDescription.
			setsDescription := ioSpecification inputSetsDescription.
			setRefsDescription := anAssessment set dataInputRefsDescription.
			associationsDescription := activity dataInputAssociationsDescription ]
		ifFalse: [
			dataItemsDescription := ioSpecification dataOutputsDescription.
			setsDescription := ioSpecification outputSetsDescription.
			setRefsDescription := anAssessment set dataOutputRefsDescription.
			associationsDescription := activity dataOutputAssociationsDescription ].

	ioMemento write: anAssessment proposedDataItems using: dataItemsDescription.
	setMemento := ioMemento childMementoFor: anAssessment set inRelation: setsDescription.
	setMemento write: anAssessment proposedSetRefs using: setRefsDescription.
	activityMemento write: anAssessment proposedAssociations using: associationsDescription.
	diagramContext writeElements: anAssessment proposedDiagramElements
]

{ #category : 'private' }
CPAtelierConnectDataAssociation >> rejectedBecause: aString [
	^ CPAtelierConnectDataAssociationAssessment
		dataReference: dataReference
		activity: activity
		rejectedBecause: aString
]

{ #category : 'accessing' }
CPAtelierConnectDataAssociation >> dataReference: anObject [ dataReference := anObject ]
{ #category : 'accessing' }
CPAtelierConnectDataAssociation >> activity: anObject [ activity := anObject ]
{ #category : 'accessing' }
CPAtelierConnectDataAssociation >> inputAssociation: aBoolean [ inputAssociation := aBoolean ]
{ #category : 'accessing' }
CPAtelierConnectDataAssociation >> processMemento: aMemento [ processMemento := aMemento ]
{ #category : 'accessing' }
CPAtelierConnectDataAssociation >> flowContainerContext: aContext [ flowContainerContext := aContext ]
{ #category : 'accessing' }
CPAtelierConnectDataAssociation >> diagramContext: aContext [ diagramContext := aContext ]
