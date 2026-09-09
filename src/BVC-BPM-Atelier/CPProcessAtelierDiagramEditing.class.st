"I adapt the Process GT editing contract to the concrete Process Atelier operations for one root Process memento."
Class {
	#name : 'CPProcessAtelierDiagramEditing',
	#superclass : 'CPProcessDiagramEditing',
	#instVars : [
		'processMemento',
		'diagramDescription'
	],
	#category : 'BVC-BPM-Atelier-Configuration',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Configuration'
}

{ #category : 'instance creation' }
CPProcessAtelierDiagramEditing class >> processMemento: aMemento diagramDescription: aDescription [
	^ self new
		processMemento: aMemento;
		diagramDescription: aDescription;
		yourself
]

{ #category : 'accessing' }
CPProcessAtelierDiagramEditing >> processMemento: aMemento [ processMemento := aMemento ]

{ #category : 'accessing' }
CPProcessAtelierDiagramEditing >> diagramDescription: aDescription [ diagramDescription := aDescription ]

{ #category : 'operation factories' }
CPProcessAtelierDiagramEditing >> createBoundaryEvent: aBoundaryEvent attachedToShape: anActivityShape bounds: proposedBounds [
	| diagramContext activity context |
	diagramContext := self processDiagramContext.
	(diagramContext elements identityIncludes: anActivityShape) ifFalse: [ ^ nil ].
	activity := diagramContext modelElementOf: anActivityShape.
	(activity notNil and: [ activity isActivity ]) ifFalse: [ ^ nil ].
	context := CPProcessFlowContainerContext containingFlowElement: activity inRootMemento: processMemento.
	context ifNil: [ ^ nil ].
	^ CPAtelierCreateBoundaryEvent
		boundaryEvent: aBoundaryEvent
		attachedTo: activity
		bounds: proposedBounds
		flowContainer: context container
		processMemento: processMemento
		diagramDescription: diagramDescription
]

{ #category : 'operation factories' }
CPProcessAtelierDiagramEditing >> createFlowNode: aFlowNode bounds: proposedBounds inProcessHostedBy: aHostShape [
	| targetContainer |
	targetContainer := self flowContainerHostedBy: aHostShape.
	targetContainer ifNil: [ ^ nil ].
	^ CPAtelierCreateFlowNode
		flowNode: aFlowNode
		bounds: proposedBounds
		flowContainer: targetContainer
		processMemento: processMemento
		diagramDescription: diagramDescription
]

{ #category : 'operation factories' }
CPProcessAtelierDiagramEditing >> createLane: aLane bounds: proposedBounds [
	^ CPAtelierCreateLane
		lane: aLane
		bounds: proposedBounds
		processMemento: processMemento
		diagramDescription: diagramDescription
]

{ #category : 'operation factories' }
CPProcessAtelierDiagramEditing >> createLaneSetWithLane: aLane bounds: proposedBounds [
	^ CPAtelierCreateLaneSetWithLane
		lane: aLane
		bounds: proposedBounds
		processMemento: processMemento
		diagramDescription: diagramDescription
]


{ #category : 'operation factories' }
CPProcessAtelierDiagramEditing >> createParticipant: aParticipant bounds: proposedBounds [
	^ CPAtelierCreateParticipant
		participant: aParticipant
		bounds: proposedBounds
		processMemento: processMemento
]


{ #category : 'operation factories' }
CPProcessAtelierDiagramEditing >> moveShapes: boundsByShape toProcessHostedBy: aHostShape waypointsByEdge: waypointsByEdge [
	| collaborationContext processDiagramContext modelElements currentContainers targetContainer boundsByFlowNode waypointsBySequenceFlow expandedBoundsByShape |
	boundsByShape ifEmpty: [ ^ nil ].

	collaborationContext := CPProcessCollaborationContext inRootMemento: processMemento.
	(collaborationContext notNil
		and: [ boundsByShape size = 1
		and: [ collaborationContext elements identityIncludes: boundsByShape keys anyOne ] ]) ifTrue: [
		^ CPAtelierMoveParticipantShape
			shape: boundsByShape keys anyOne
			bounds: boundsByShape values anyOne
			processMemento: processMemento ].

	targetContainer := self flowContainerHostedBy: aHostShape.
	targetContainer ifNil: [ ^ nil ].
	processDiagramContext := self processDiagramContext.
	expandedBoundsByShape := self
		boundsByShapeIncludingAttachedBoundaryEvents: boundsByShape
		diagramContext: processDiagramContext.
	modelElements := expandedBoundsByShape keys collect: [ :aShape |
		processDiagramContext modelElementOf: aShape ].
	currentContainers := IdentitySet new.
	modelElements do: [ :each |
		(CPProcessFlowContainerContext
			containingFlowElement: each
			inRootMemento: processMemento)
			ifNotNil: [ :aContext | currentContainers add: aContext container ] ].

	(targetContainer notNil
		and: [ currentContainers size = 1
		and: [ currentContainers anyOne ~~ targetContainer ] ]) ifTrue: [
		boundsByFlowNode := IdentityDictionary new.
		expandedBoundsByShape keysAndValuesDo: [ :aShape :proposedBounds |
			boundsByFlowNode
				at: (processDiagramContext modelElementOf: aShape)
				put: proposedBounds ].
		modelElements size = 1 ifTrue: [
			^ CPAtelierTransferFlowNode
				flowNode: modelElements anyOne
				targetContainer: targetContainer
				bounds: boundsByFlowNode values anyOne
				processMemento: processMemento
				diagramDescription: diagramDescription ].
		waypointsBySequenceFlow := IdentityDictionary new.
		waypointsByEdge keysAndValuesDo: [ :anEdge :someWaypoints |
			waypointsBySequenceFlow
				at: (processDiagramContext modelElementOf: anEdge)
				put: someWaypoints ].
		^ CPAtelierTransferFlowNodes
			flowNodes: modelElements
			targetContainer: targetContainer
			boundsByFlowNode: boundsByFlowNode
			waypointsBySequenceFlow: waypointsBySequenceFlow
			processMemento: processMemento
			diagramDescription: diagramDescription ].

	^ CPAtelierMoveShapes
		boundsByShape: expandedBoundsByShape
		processMemento: processMemento
		diagramDescription: diagramDescription
]

{ #category : 'private - containment' }
CPProcessAtelierDiagramEditing >> boundsByShapeIncludingAttachedBoundaryEvents: boundsByShape diagramContext: aDiagramContext [
	| expanded |
	expanded := boundsByShape copy.
	boundsByShape keysAndValuesDo: [ :aShape :proposedBounds |
		| modelElement context currentBounds delta |
		modelElement := aDiagramContext modelElementOf: aShape.
		(modelElement notNil and: [ modelElement isActivity ]) ifTrue: [
			context := CPProcessFlowContainerContext
				containingFlowElement: modelElement
				inRootMemento: processMemento.
			context ifNotNil: [
				currentBounds := aDiagramContext boundsOf: aShape.
				delta := proposedBounds origin - currentBounds origin.
				(context attachedBoundaryEventsFor: modelElement) do: [ :aBoundaryEvent |
					| boundaryShapes boundaryShape |
					boundaryShapes := aDiagramContext shapesForModelElement: aBoundaryEvent.
					boundaryShapes size = 1 ifTrue: [
						boundaryShape := boundaryShapes first.
						(expanded includesKey: boundaryShape) ifFalse: [
							expanded
								at: boundaryShape
								put: ((aDiagramContext boundsOf: boundaryShape) translateBy: delta) ] ] ] ] ] ].
	^ expanded
]

{ #category : 'private - staged state' }
CPProcessAtelierDiagramEditing >> processDiagramContext [
	| diagram |
	diagram := processMemento readUsing: diagramDescription.
	^ CPDiagramMementoContext
		diagram: diagram
		inMemento: processMemento
		using: diagramDescription
]



{ #category : 'private - staged state' }
CPProcessAtelierDiagramEditing >> diagramContextContaining: aDiagramElement [
	| collaborationContext processDiagramContext |
	collaborationContext := CPProcessCollaborationContext inRootMemento: processMemento.
	(collaborationContext notNil
		and: [ collaborationContext elements identityIncludes: aDiagramElement ]) ifTrue: [
		^ collaborationContext diagramContext ].
	processDiagramContext := self processDiagramContext.
	(processDiagramContext elements identityIncludes: aDiagramElement) ifTrue: [
		^ processDiagramContext ].
	^ nil
]

{ #category : 'operation factories' }
CPProcessAtelierDiagramEditing >> reattachBoundaryEvent: aBoundaryEventShape toActivityShape: anActivityShape bounds: proposedBounds [
	| diagramContext boundaryEvent activity boundaryContext activityContext |
	diagramContext := self processDiagramContext.
	((diagramContext elements identityIncludes: aBoundaryEventShape)
		and: [ diagramContext elements identityIncludes: anActivityShape ]) ifFalse: [ ^ nil ].
	boundaryEvent := diagramContext modelElementOf: aBoundaryEventShape.
	activity := diagramContext modelElementOf: anActivityShape.
	(boundaryEvent notNil and: [ boundaryEvent isBoundaryEvent ]) ifFalse: [ ^ nil ].
	(activity notNil and: [ activity isActivity ]) ifFalse: [ ^ nil ].
	boundaryContext := CPProcessFlowContainerContext containingFlowElement: boundaryEvent inRootMemento: processMemento.
	activityContext := CPProcessFlowContainerContext containingFlowElement: activity inRootMemento: processMemento.
	(boundaryContext notNil and: [ activityContext notNil ]) ifFalse: [ ^ nil ].
	boundaryContext container == activityContext container ifFalse: [ ^ nil ].
	^ CPAtelierReattachBoundaryEvent
		boundaryEvent: boundaryEvent
		shape: aBoundaryEventShape
		attachedTo: activity
		bounds: proposedBounds
		flowContainer: boundaryContext container
		processMemento: processMemento
		diagramDescription: diagramDescription
]

{ #category : 'operation factories' }
CPProcessAtelierDiagramEditing >> resizeShape: aShape toBounds: proposedBounds [
	| collaborationContext |
	collaborationContext := CPProcessCollaborationContext inRootMemento: processMemento.
	(collaborationContext notNil
		and: [ collaborationContext elements identityIncludes: aShape ]) ifTrue: [
		^ CPAtelierResizeParticipantShape
			shape: aShape
			bounds: proposedBounds
			processMemento: processMemento ].
	^ CPAtelierResizeShape
		shape: aShape
		bounds: proposedBounds
		processMemento: processMemento
		diagramDescription: diagramDescription
]

{ #category : 'operation factories' }
CPProcessAtelierDiagramEditing >> replaceShape: aShape with: aReplacementNode bounds: proposedBounds [
	| flowNode flowContainer |
	flowNode := self modelElementOfDiagramElement: aShape.
	flowNode ifNil: [ ^ nil ].
	flowContainer := self flowContainerContaining: flowNode.
	flowContainer ifNil: [ ^ nil ].
	^ CPAtelierReplaceFlowNode
		flowNode: flowNode
		with: aReplacementNode
		bounds: proposedBounds
		flowContainer: flowContainer
		processMemento: processMemento
		diagramDescription: diagramDescription
]


{ #category : 'operation factories' }
CPProcessAtelierDiagramEditing >> appendFlowNode: aFlowNode fromShape: aSourceShape bounds: proposedBounds [
	| source flowContainer |
	source := self modelElementOfDiagramElement: aSourceShape.
	source ifNil: [ ^ nil ].
	flowContainer := self flowContainerContaining: source.
	flowContainer ifNil: [ ^ nil ].
	^ CPAtelierAppendFlowNode
		source: source
		flowNode: aFlowNode
		bounds: proposedBounds
		flowContainer: flowContainer
		processMemento: processMemento
		diagramDescription: diagramDescription
]

{ #category : 'operation factories' }
CPProcessAtelierDiagramEditing >> connectFrom: aSourceShape to: aTargetShape waypoints: someWaypoints [
	| source target sourceContainer targetContainer |
	source := self modelElementOfDiagramElement: aSourceShape.
	target := self modelElementOfDiagramElement: aTargetShape.
	(source isNil or: [ target isNil ]) ifTrue: [ ^ nil ].
	sourceContainer := self flowContainerContaining: source.
	targetContainer := self flowContainerContaining: target.
	(sourceContainer notNil and: [ sourceContainer == targetContainer ]) ifTrue: [
		^ CPAtelierConnectFlowNodes
			source: source
			target: target
			flowContainer: sourceContainer
			processMemento: processMemento
			diagramDescription: diagramDescription ].
	^ CPAtelierConnectMessageFlow
		source: source
		target: target
		waypoints: someWaypoints
		processMemento: processMemento
]

{ #category : 'private - staged state' }
CPProcessAtelierDiagramEditing >> flowContainerContaining: aModelElement [
	| context |
	context := CPProcessFlowContainerContext
		containingFlowElement: aModelElement
		inRootMemento: processMemento.
	^ context ifNotNil: [ context container ]
]


{ #category : 'private - staged state' }
CPProcessAtelierDiagramEditing >> flowContainerHostedBy: aHostShape [
	| hostModelElement |
	aHostShape ifNil: [ ^ processMemento model ].
	hostModelElement := self modelElementOfDiagramElement: aHostShape.
	(hostModelElement notNil and: [ hostModelElement isSubProcess ])
		ifFalse: [ ^ nil ].
	^ (CPProcessFlowContainerContext
		forContainer: hostModelElement
		inRootMemento: processMemento)
		ifNotNil: [ :aContext | aContext container ]
]

{ #category : 'private - staged state' }
CPProcessAtelierDiagramEditing >> modelElementOfDiagramElement: aDiagramElement [
	| collaborationContext collaborationDiagramContext processDiagramContext |
	collaborationContext := CPProcessCollaborationContext inRootMemento: processMemento.
	(collaborationContext notNil
		and: [ collaborationContext elements identityIncludes: aDiagramElement ]) ifTrue: [
		collaborationDiagramContext := collaborationContext diagramContext.
		^ collaborationDiagramContext modelElementOf: aDiagramElement ].
	processDiagramContext := self processDiagramContext.
	(processDiagramContext elements identityIncludes: aDiagramElement) ifTrue: [
		^ processDiagramContext modelElementOf: aDiagramElement ].
	^ nil
]

{ #category : 'operation factories' }
CPProcessAtelierDiagramEditing >> insertFlowNode: aFlowNode intoEdge: anEdge bounds: proposedBounds [
	| sequenceFlow flowContainer |
	sequenceFlow := self modelElementOfDiagramElement: anEdge.
	sequenceFlow ifNil: [ ^ nil ].
	flowContainer := self flowContainerContaining: sequenceFlow.
	flowContainer ifNil: [ ^ nil ].
	^ CPAtelierInsertFlowNode
		sequenceFlow: sequenceFlow
		flowNode: aFlowNode
		bounds: proposedBounds
		flowContainer: flowContainer
		processMemento: processMemento
		diagramDescription: diagramDescription
]

{ #category : 'operation factories' }
CPProcessAtelierDiagramEditing >> remove: someDiagramElements [
	someDiagramElements ifEmpty: [ ^ nil ].
	^ CPAtelierRemoveDiagramElements
		diagramElements: someDiagramElements
		processMemento: processMemento
		diagramDescription: diagramDescription
]

{ #category : 'operation factories' }
CPProcessAtelierDiagramEditing >> reconnectEdge: anEdge sourceShape: aSourceShape targetShape: aTargetShape waypoints: someWaypoints [
	| collaborationContext modelEdge source target flowContainer |
	modelEdge := self modelElementOfDiagramElement: anEdge.
	source := self modelElementOfDiagramElement: aSourceShape.
	target := self modelElementOfDiagramElement: aTargetShape.
	(modelEdge isNil or: [ source isNil or: [ target isNil ] ]) ifTrue: [ ^ nil ].

	collaborationContext := CPProcessCollaborationContext inRootMemento: processMemento.
	(collaborationContext notNil and: [ collaborationContext elements identityIncludes: anEdge ]) ifTrue: [
		^ CPAtelierReconnectMessageFlow
			messageFlow: modelEdge
			source: source
			target: target
			waypoints: someWaypoints
			processMemento: processMemento ].

	flowContainer := self flowContainerContaining: modelEdge.
	flowContainer ifNil: [ ^ nil ].
	^ CPAtelierReconnectSequenceFlow
		sequenceFlow: modelEdge
		source: source
		target: target
		waypoints: someWaypoints
		flowContainer: flowContainer
		processMemento: processMemento
		diagramDescription: diagramDescription
]


{ #category : 'operation factories' }
CPProcessAtelierDiagramEditing >> setBoundaryEventDefinitionClass: aDefinitionClass forShape: aBoundaryEventShape [
	| boundaryEvent flowContainer |
	boundaryEvent := self modelElementOfDiagramElement: aBoundaryEventShape.
	(boundaryEvent notNil and: [ boundaryEvent isBoundaryEvent ]) ifFalse: [ ^ nil ].
	flowContainer := self flowContainerContaining: boundaryEvent.
	flowContainer ifNil: [ ^ nil ].
	^ CPAtelierSetBoundaryEventDefinition
		boundaryEvent: boundaryEvent
		definitionClass: aDefinitionClass
		flowContainer: flowContainer
		processMemento: processMemento
]

{ #category : 'operation factories' }
CPProcessAtelierDiagramEditing >> setShape: aShape expanded: aBoolean [
	^ CPAtelierSetShapeExpanded
		shape: aShape
		expanded: aBoolean
		processMemento: processMemento
		diagramDescription: diagramDescription
]

{ #category : 'operation factories' }
CPProcessAtelierDiagramEditing >> setWaypoints: someWaypoints forEdge: anEdge [
	| edgeDiagramContext |
	edgeDiagramContext := self diagramContextContaining: anEdge.
	edgeDiagramContext ifNil: [ ^ nil ].
	^ CPAtelierSetEdgeWaypoints
		edge: anEdge
		waypoints: someWaypoints
		diagramContext: edgeDiagramContext
]

{ #category : 'operation factories' }
CPProcessAtelierDiagramEditing >> setLabelSegmentIndex: aSegmentIndex segmentPosition: aSegmentPosition offset: anOffset forEdge: anEdge [
	| edgeDiagramContext |
	edgeDiagramContext := self diagramContextContaining: anEdge.
	edgeDiagramContext ifNil: [ ^ nil ].
	^ CPAtelierSetEdgeLabelPlacement
		edge: anEdge
		segmentIndex: aSegmentIndex
		segmentPosition: aSegmentPosition
		offset: anOffset
		diagramContext: edgeDiagramContext
]



{ #category : 'operation factories' }
CPProcessAtelierDiagramEditing >> insertLane: aLane relativeTo: aTargetLane after: aBoolean [
	^ CPAtelierInsertLane
		lane: aLane
		relativeTo: aTargetLane
		after: aBoolean
		processMemento: processMemento
		diagramDescription: diagramDescription
]


{ #category : 'operation factories' }
CPProcessAtelierDiagramEditing >> addChildLane: aLane toParentLane: aParentLane bounds: proposedBounds [
	^ CPAtelierAddChildLane
		lane: aLane
		toParentLane: aParentLane
		bounds: proposedBounds
		processMemento: processMemento
		diagramDescription: diagramDescription
]
