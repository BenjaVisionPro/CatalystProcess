"I adapt the Process GT editing contract to concrete assessed operations for one Process editing session.

The session supplies the semantic Process memento, active depiction and optional Collaboration context explicitly."
Class {
	#name : 'CPProcessAtelierDiagramEditing',
	#superclass : 'CPProcessDiagramEditing',
	#instVars : [
		'processMemento',
		'diagramContext',
		'collaborationContext',
		'documentContext'
	],
	#category : 'BVC-BPM-Atelier-Configuration',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Configuration'
}

{ #category : 'instance creation' }
CPProcessAtelierDiagramEditing class >> processMemento: aMemento diagramContext: aDiagramContext [
	^ self processMemento: aMemento diagramContext: aDiagramContext collaborationContext: nil documentContext: nil
]

{ #category : 'instance creation' }
CPProcessAtelierDiagramEditing class >> processMemento: aMemento diagramContext: aDiagramContext collaborationContext: aCollaborationContext [
	^ self processMemento: aMemento diagramContext: aDiagramContext collaborationContext: aCollaborationContext documentContext: nil
]

{ #category : 'instance creation' }
CPProcessAtelierDiagramEditing class >> processMemento: aMemento diagramContext: aDiagramContext collaborationContext: aCollaborationContext documentContext: aDocumentContext [
	^ self new
		processMemento: aMemento;
		diagramContext: aDiagramContext;
		collaborationContext: aCollaborationContext;
		documentContext: aDocumentContext;
		yourself
]

{ #category : 'accessing' }
CPProcessAtelierDiagramEditing >> processMemento: aMemento [ processMemento := aMemento ]


{ #category : 'accessing' }
CPProcessAtelierDiagramEditing >> diagramContext: aDiagramContext [ diagramContext := aDiagramContext ]

{ #category : 'accessing' }
CPProcessAtelierDiagramEditing >> collaborationContext: aCollaborationContext [ collaborationContext := aCollaborationContext ]

{ #category : 'accessing' }
CPProcessAtelierDiagramEditing >> documentContext: aDocumentContext [ documentContext := aDocumentContext ]

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
		diagramContext: diagramContext
]

{ #category : 'operation factories' }
CPProcessAtelierDiagramEditing >> createFlowNode: aFlowNode bounds: proposedBounds inProcessHostedBy: aHostShape [
	^ self
		createFlowNode: aFlowNode
		bounds: proposedBounds
		inProcessHostedBy: aHostShape
		targetLane: nil
]

{ #category : 'operation factories' }
CPProcessAtelierDiagramEditing >> createFlowNode: aFlowNode bounds: proposedBounds inProcessHostedBy: aHostShape targetLane: aLane [
	| targetContainer operation |
	targetContainer := self flowContainerHostedBy: aHostShape.
	targetContainer ifNil: [ ^ nil ].
	operation := CPAtelierCreateFlowNode
		flowNode: aFlowNode
		bounds: proposedBounds
		flowContainer: targetContainer
		processMemento: processMemento
		diagramContext: diagramContext.
	operation targetLane: aLane.
	^ operation
]

{ #category : 'operation factories' }
CPProcessAtelierDiagramEditing >> createLane: aLane bounds: proposedBounds [
	^ CPAtelierCreateLane
		lane: aLane
		bounds: proposedBounds
		processMemento: processMemento
		diagramContext: diagramContext
		collaborationContext: self stagedCollaborationContext
]

{ #category : 'operation factories' }
CPProcessAtelierDiagramEditing >> createLaneSetWithLane: aLane bounds: proposedBounds [
	^ CPAtelierCreateLaneSetWithLane
		lane: aLane
		bounds: proposedBounds
		processMemento: processMemento
		diagramContext: diagramContext
		collaborationContext: self stagedCollaborationContext
]


{ #category : 'operation factories' }
CPProcessAtelierDiagramEditing >> createParticipant: aParticipant bounds: proposedBounds [
	^ CPAtelierCreateParticipant
		participant: aParticipant
		bounds: proposedBounds
		processMemento: processMemento
		documentContext: documentContext
		collaborationContext: self stagedCollaborationContext
]


{ #category : 'operation factories' }
CPProcessAtelierDiagramEditing >> moveShapes: boundsByShape toProcessHostedBy: aHostShape waypointsByEdge: waypointsByEdge [
	| processDiagramContext modelElements currentContainers targetContainer boundsByFlowNode waypointsBySequenceFlow expandedBoundsByShape currentCollaborationContext |
	boundsByShape ifEmpty: [ ^ nil ].


	currentCollaborationContext := self stagedCollaborationContext.
	(currentCollaborationContext notNil
		and: [ boundsByShape size = 1
		and: [ currentCollaborationContext elements identityIncludes: boundsByShape keys anyOne ] ]) ifTrue: [
		^ CPAtelierMoveParticipantShape
			shape: boundsByShape keys anyOne
			bounds: boundsByShape values anyOne
			processMemento: processMemento
			collaborationContext: currentCollaborationContext ].

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
				diagramContext: diagramContext ].
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
			diagramContext: diagramContext ].

	^ CPAtelierMoveShapes
		boundsByShape: expandedBoundsByShape
		processMemento: processMemento
		diagramContext: diagramContext
]

{ #category : 'private - containment' }
CPProcessAtelierDiagramEditing >> boundsByShapeIncludingAttachedBoundaryEvents: boundsByShape diagramContext: aDiagramContext [
	| expanded |
	expanded := boundsByShape copy.
	boundsByShape keysAndValuesDo: [ :aShape :proposedBounds |
		| modelElement context currentBounds delta |
		modelElement := aDiagramContext modelElementOf: aShape.
		modelElement ifNotNil: [
			context := CPProcessFlowContainerContext
				containingFlowElement: modelElement
				inRootMemento: processMemento.
			(context notNil and: [ modelElement isActivity ]) ifTrue: [
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
CPProcessAtelierDiagramEditing >> stagedCollaborationContext [
	documentContext ifNotNil: [
		^ CPProcessCollaborationContext
			forProcessMemento: processMemento
			documentContext: documentContext ].
	^ collaborationContext
]

{ #category : 'private - staged state' }
CPProcessAtelierDiagramEditing >> processDiagramContext [
	^ diagramContext
]



{ #category : 'private - staged state' }
CPProcessAtelierDiagramEditing >> diagramContextContaining: aDiagramElement [
	| processDiagramContext currentCollaborationContext |
	currentCollaborationContext := self stagedCollaborationContext.
	(currentCollaborationContext notNil
		and: [ currentCollaborationContext elements identityIncludes: aDiagramElement ]) ifTrue: [
		^ currentCollaborationContext diagramContext ].
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
		diagramContext: diagramContext
]

{ #category : 'operation factories' }
CPProcessAtelierDiagramEditing >> resizeShape: aShape toBounds: proposedBounds [
	| currentCollaborationContext |
	currentCollaborationContext := self stagedCollaborationContext.
	(currentCollaborationContext notNil
		and: [ currentCollaborationContext elements identityIncludes: aShape ]) ifTrue: [
		^ CPAtelierResizeParticipantShape
			shape: aShape
			bounds: proposedBounds
			processMemento: processMemento
			collaborationContext: currentCollaborationContext
			processDiagramContext: diagramContext ].
	^ CPAtelierResizeShape
		shape: aShape
		bounds: proposedBounds
		processMemento: processMemento
		diagramContext: diagramContext
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
		diagramContext: diagramContext
]


{ #category : 'operation factories' }
CPProcessAtelierDiagramEditing >> appendFlowNode: aFlowNode fromShape: aSourceShape bounds: proposedBounds [
	^ self
		appendFlowNode: aFlowNode
		fromShape: aSourceShape
		bounds: proposedBounds
		targetLane: nil
]

{ #category : 'operation factories' }
CPProcessAtelierDiagramEditing >> appendFlowNode: aFlowNode fromShape: aSourceShape bounds: proposedBounds targetLane: aLane [
	| source flowContainer operation |
	source := self modelElementOfDiagramElement: aSourceShape.
	source ifNil: [ ^ nil ].
	flowContainer := self flowContainerContaining: source.
	flowContainer ifNil: [ ^ nil ].
	operation := CPAtelierAppendFlowNode
		source: source
		flowNode: aFlowNode
		bounds: proposedBounds
		flowContainer: flowContainer
		processMemento: processMemento
		diagramContext: diagramContext.
	operation targetLane: aLane.
	^ operation
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
			diagramContext: diagramContext ].
	^ CPAtelierConnectMessageFlow
		source: source
		target: target
		waypoints: someWaypoints
		processMemento: processMemento
		collaborationContext: self stagedCollaborationContext
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
	| collaborationDiagramContext processDiagramContext currentCollaborationContext |
	currentCollaborationContext := self stagedCollaborationContext.
	(currentCollaborationContext notNil
		and: [ currentCollaborationContext elements identityIncludes: aDiagramElement ]) ifTrue: [
		collaborationDiagramContext := currentCollaborationContext diagramContext.
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
		diagramContext: diagramContext
]

{ #category : 'operation factories' }
CPProcessAtelierDiagramEditing >> remove: someDiagramElements [
	someDiagramElements ifEmpty: [ ^ nil ].
	^ CPAtelierRemoveDiagramElements
		diagramElements: someDiagramElements
		processMemento: processMemento
		diagramContext: diagramContext
		documentContext: documentContext
		collaborationContext: self stagedCollaborationContext
]

{ #category : 'operation factories' }
CPProcessAtelierDiagramEditing >> reconnectEdge: anEdge sourceShape: aSourceShape targetShape: aTargetShape waypoints: someWaypoints [
	| modelEdge source target flowContainer currentCollaborationContext |
	modelEdge := self modelElementOfDiagramElement: anEdge.
	source := self modelElementOfDiagramElement: aSourceShape.
	target := self modelElementOfDiagramElement: aTargetShape.
	(modelEdge isNil or: [ source isNil or: [ target isNil ] ]) ifTrue: [ ^ nil ].

	currentCollaborationContext := self stagedCollaborationContext.
	(currentCollaborationContext notNil and: [ currentCollaborationContext elements identityIncludes: anEdge ]) ifTrue: [
		^ CPAtelierReconnectMessageFlow
			messageFlow: modelEdge
			source: source
			target: target
			waypoints: someWaypoints
			processMemento: processMemento
			collaborationContext: currentCollaborationContext ].

	flowContainer := self flowContainerContaining: modelEdge.
	flowContainer ifNil: [ ^ nil ].
	^ CPAtelierReconnectSequenceFlow
		sequenceFlow: modelEdge
		source: source
		target: target
		waypoints: someWaypoints
		flowContainer: flowContainer
		processMemento: processMemento
		diagramContext: diagramContext
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
		diagramContext: diagramContext
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
		diagramContext: diagramContext
		collaborationContext: self stagedCollaborationContext
]


{ #category : 'operation factories' }
CPProcessAtelierDiagramEditing >> addChildLane: aLane toParentLane: aParentLane bounds: proposedBounds [
	^ CPAtelierAddChildLane
		lane: aLane
		toParentLane: aParentLane
		bounds: proposedBounds
		processMemento: processMemento
		diagramContext: diagramContext
]


{ #category : 'operation factories' }
CPProcessAtelierDiagramEditing >> assignFlowNode: aFlowNode toLane: aLane [
	^ CPAtelierAssignFlowNodeToLane
		flowNode: aFlowNode
		targetLane: aLane
		processMemento: processMemento
]


{ #category : 'operation factories' }
CPProcessAtelierDiagramEditing >> moveFlowNode: aFlowNode shape: aShape bounds: aRectangle fromLane: aSourceLane toLane: aTargetLane [
	^ CPAtelierMoveFlowNodeToLane
		flowNode: aFlowNode
		shape: aShape
		bounds: aRectangle
		sourceLane: aSourceLane
		targetLane: aTargetLane
		processMemento: processMemento
		diagramContext: diagramContext
]

{ #category : 'geometry preview' }
CPProcessAtelierDiagramEditing >> laneBoundsPreviewForResizeShape: aShape toBounds: proposedBounds [
	| operation assessment |
	operation := self resizeShape: aShape toBounds: proposedBounds.
	operation ifNil: [ ^ nil ].
	assessment := operation assess.
	assessment isApplicable ifFalse: [ ^ nil ].
	^ assessment proposedLaneBoundsByShape
]

{ #category : 'geometry preview' }
CPProcessAtelierDiagramEditing >> flowNodeBoundsPreviewForResizeShape: aShape toBounds: proposedBounds [
	| operation assessment |
	operation := self resizeShape: aShape toBounds: proposedBounds.
	operation ifNil: [ ^ nil ].
	assessment := operation assess.
	assessment isApplicable ifFalse: [ ^ nil ].
	^ assessment proposedFlowNodeBoundsByShape
]


{ #category : 'geometry preview' }
CPProcessAtelierDiagramEditing >> waypointsPreviewForResizeShape: aShape toBounds: proposedBounds [
	| operation assessment |
	operation := self resizeShape: aShape toBounds: proposedBounds.
	operation ifNil: [ ^ nil ].
	assessment := operation assess.
	assessment isApplicable ifFalse: [ ^ nil ].
	^ assessment proposedWaypointsByEdge
]


{ #category : 'geometry constraints' }
CPProcessAtelierDiagramEditing >> minimumHeightForResizeShape: aShape [
	| collaboration participant operation |
	collaboration := self stagedCollaborationContext.
	collaboration ifNil: [ ^ nil ].
	(collaboration elements identityIncludes: aShape) ifFalse: [ ^ nil ].
	participant := collaboration diagramContext modelElementOf: aShape.
	(collaboration processRefOf: participant) == processMemento model ifFalse: [ ^ nil ].
	operation := CPAtelierResizeParticipantShape
		shape: aShape
		bounds: (collaboration diagramContext boundsOf: aShape)
		processMemento: processMemento
		collaborationContext: collaboration
		processDiagramContext: diagramContext.
	^ operation minimumParticipantHeightForStagedLanes
]
