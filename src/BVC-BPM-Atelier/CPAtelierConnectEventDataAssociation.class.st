"I stage one BPMN Data Association between a depicted Data Object Reference and an Event.

A Data Object Reference -> Throw Event connection creates a CPDataInput, places it in the Event InputSet and creates a CPDataInputAssociation. The DI edge ends visually at the Event shape.

A Catch Event -> Data Object Reference connection creates a CPDataOutput, places it in the Event OutputSet and creates a CPDataOutputAssociation. The DI edge starts visually at the Event shape."
Class {
	#name : 'CPAtelierConnectEventDataAssociation',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'dataReference',
		'event',
		'catchAssociation',
		'flowContainerContext',
		'diagramContext'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierConnectEventDataAssociation class >> dataReference: aReference toThrowEvent: anEvent flowContainer: aContainer processMemento: aMemento diagramContext: aDiagramContext [
	^ self new
		dataReference: aReference;
		event: anEvent;
		catchAssociation: false;
		flowContainerContext: (CPProcessFlowContainerContext forContainer: aContainer inRootMemento: aMemento);
		diagramContext: aDiagramContext;
		yourself
]

{ #category : 'instance creation' }
CPAtelierConnectEventDataAssociation class >> catchEvent: anEvent toDataReference: aReference flowContainer: aContainer processMemento: aMemento diagramContext: aDiagramContext [
	^ self new
		dataReference: aReference;
		event: anEvent;
		catchAssociation: true;
		flowContainerContext: (CPProcessFlowContainerContext forContainer: aContainer inRootMemento: aMemento);
		diagramContext: aDiagramContext;
		yourself
]

{ #category : 'assessing' }
CPAtelierConnectEventDataAssociation >> assess [
	| flowElements eventMemento dataItem dataItemsDescription currentDataItems setDescription set setMemento setRefsDescription currentSetRefs association associationsDescription currentAssociations proposedDataItems proposedSetRefs proposedAssociations dataShape eventShape edge proposedElements |
	flowContainerContext ifNil: [ ^ self rejectedBecause: 'The target flow container is not present in staged state.' ].
	flowElements := flowContainerContext stagedFlowElements.
	(flowElements identityIncludes: dataReference) ifFalse: [ ^ self rejectedBecause: 'The Data Object Reference does not belong to the target flow container.' ].
	(flowElements identityIncludes: event) ifFalse: [ ^ self rejectedBecause: 'The Event does not belong to the target flow container.' ].
	dataReference isDataObjectReference ifFalse: [ ^ self rejectedBecause: 'A Data Object Reference is required.' ].
	catchAssociation
		ifTrue: [ event isCatchEvent ifFalse: [ ^ self rejectedBecause: 'A Catch Event is required for Event output data.' ] ]
		ifFalse: [ event isThrowEvent ifFalse: [ ^ self rejectedBecause: 'A Throw Event is required for Event input data.' ] ].

	eventMemento := flowContainerContext childMementoFor: event.
	catchAssociation
		ifTrue: [
			dataItem := CPDataOutput new
				label: dataReference label;
				itemSubjectRef: dataReference itemSubjectRef;
				yourself.
			dataItemsDescription := event dataOutputsDescription.
			currentDataItems := eventMemento readUsing: dataItemsDescription.
			setDescription := event outputSetDescription.
			set := eventMemento readUsing: setDescription.
			set ifNil: [ set := CPOutputSet new ].
			setRefsDescription := set dataOutputRefsDescription.
			association := CPDataOutputAssociation new
				sourceRefs: { dataItem };
				targetRef: dataReference;
				yourself.
			associationsDescription := event dataOutputAssociationsDescription ]
		ifFalse: [
			dataItem := CPDataInput new
				label: dataReference label;
				itemSubjectRef: dataReference itemSubjectRef;
				yourself.
			dataItemsDescription := event dataInputsDescription.
			currentDataItems := eventMemento readUsing: dataItemsDescription.
			setDescription := event inputSetDescription.
			set := eventMemento readUsing: setDescription.
			set ifNil: [ set := CPInputSet new ].
			setRefsDescription := set dataInputRefsDescription.
			association := CPDataInputAssociation new
				sourceRefs: { dataReference };
				targetRef: dataItem;
				yourself.
			associationsDescription := event dataInputAssociationsDescription ].

	(eventMemento readUsing: setDescription) ifNil: [
		[ setDescription validate: set ]
			on: MAValidationError
			do: [ :anException | ^ self rejectedBecause: anException printString ] ].
	setMemento := (eventMemento readUsing: setDescription)
		ifNil: [ nil ]
		ifNotNil: [ eventMemento childMementoFor: set inRelation: setDescription ].
	currentSetRefs := setMemento
		ifNil: [ catchAssociation ifTrue: [ set dataOutputRefs ] ifFalse: [ set dataInputRefs ] ]
		ifNotNil: [ setMemento readUsing: setRefsDescription ].
	currentAssociations := eventMemento readUsing: associationsDescription.

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
	eventShape := diagramContext shapeForModelElement: event.
	(dataShape isNil or: [ eventShape isNil ]) ifTrue: [ ^ self rejectedBecause: 'Both Data Association endpoints require diagram shapes.' ].
	edge := CPEdge new modelElement: association; yourself.
	catchAssociation
		ifTrue: [ edge sourceElement: eventShape; targetElement: dataShape ]
		ifFalse: [ edge sourceElement: dataShape; targetElement: eventShape ].
	edge
		addWaypoint: (diagramContext boundsOf: edge sourceElement) center;
		addWaypoint: (diagramContext boundsOf: edge targetElement) center.
	proposedElements := diagramContext elements asOrderedCollection copy.
	proposedElements add: edge.
	[ diagramContext validateElements: proposedElements ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	^ CPAtelierConnectEventDataAssociationAssessment
		dataReference: dataReference
		event: event
		association: association
		dataItem: dataItem
		set: set
		edge: edge
		catchAssociation: catchAssociation
		proposedDataItems: proposedDataItems
		proposedSetRefs: proposedSetRefs
		proposedAssociations: proposedAssociations
		proposedDiagramElements: proposedElements
]

{ #category : 'applying' }
CPAtelierConnectEventDataAssociation >> applyAssessment: anAssessment [
	| eventMemento dataItemsDescription setDescription set associationsDescription setMemento setRefsDescription |
	eventMemento := flowContainerContext childMementoFor: event.
	anAssessment catchAssociation
		ifTrue: [
			dataItemsDescription := event dataOutputsDescription.
			setDescription := event outputSetDescription.
			associationsDescription := event dataOutputAssociationsDescription ]
		ifFalse: [
			dataItemsDescription := event dataInputsDescription.
			setDescription := event inputSetDescription.
			associationsDescription := event dataInputAssociationsDescription ].
	set := eventMemento readUsing: setDescription.
	set ifNil: [
		eventMemento write: anAssessment set using: setDescription.
		set := anAssessment set ].
	setRefsDescription := anAssessment catchAssociation
		ifTrue: [ set dataOutputRefsDescription ]
		ifFalse: [ set dataInputRefsDescription ].
	setMemento := eventMemento childMementoFor: set inRelation: setDescription.
	eventMemento write: anAssessment proposedDataItems using: dataItemsDescription.
	setMemento write: anAssessment proposedSetRefs using: setRefsDescription.
	eventMemento write: anAssessment proposedAssociations using: associationsDescription.
	diagramContext writeElements: anAssessment proposedDiagramElements
]

{ #category : 'private' }
CPAtelierConnectEventDataAssociation >> rejectedBecause: aString [
	^ CPAtelierConnectEventDataAssociationAssessment
		dataReference: dataReference
		event: event
		rejectedBecause: aString
]

{ #category : 'accessing' }
CPAtelierConnectEventDataAssociation >> dataReference: anObject [ dataReference := anObject ]
{ #category : 'accessing' }
CPAtelierConnectEventDataAssociation >> event: anObject [ event := anObject ]
{ #category : 'accessing' }
CPAtelierConnectEventDataAssociation >> catchAssociation: aBoolean [ catchAssociation := aBoolean ]
{ #category : 'accessing' }
CPAtelierConnectEventDataAssociation >> flowContainerContext: aContext [ flowContainerContext := aContext ]
{ #category : 'accessing' }
CPAtelierConnectEventDataAssociation >> diagramContext: aContext [ diagramContext := aContext ]
