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
CPProcessAtelierDiagramEditing >> create: aModelElement bounds: proposedBounds flowContainer: aFlowContainer [
	aModelElement isParticipant ifTrue: [
		^ CPAtelierCreateParticipant
			participant: aModelElement
			bounds: proposedBounds
			processMemento: processMemento ].
	^ CPAtelierCreateFlowNode
		flowNode: aModelElement
		bounds: proposedBounds
		flowContainer: aFlowContainer
		processMemento: processMemento
		diagramDescription: diagramDescription
]


{ #category : 'operation factories' }
CPProcessAtelierDiagramEditing >> moveShapes: boundsByShape toFlowContainer: aTargetContainer waypointsByEdge: waypointsByEdge [
	| collaborationContext processDiagramContext modelElements currentContainers boundsByFlowNode waypointsBySequenceFlow |
	boundsByShape ifEmpty: [ ^ nil ].

	collaborationContext := CPProcessCollaborationContext inRootMemento: processMemento.
	(collaborationContext notNil
		and: [ boundsByShape size = 1
		and: [ collaborationContext elements identityIncludes: boundsByShape keys anyOne ] ]) ifTrue: [
		^ CPAtelierMoveParticipantShape
			shape: boundsByShape keys anyOne
			bounds: boundsByShape values anyOne
			processMemento: processMemento ].

	processDiagramContext := self processDiagramContext.
	modelElements := boundsByShape keys collect: [ :aShape |
		processDiagramContext modelElementOf: aShape ].
	currentContainers := IdentitySet new.
	modelElements do: [ :each |
		(CPProcessFlowContainerContext
			containingFlowElement: each
			inRootMemento: processMemento)
			ifNotNil: [ :aContext | currentContainers add: aContext container ] ].

	(aTargetContainer notNil
		and: [ currentContainers size = 1
		and: [ currentContainers anyOne ~~ aTargetContainer ] ]) ifTrue: [
		boundsByFlowNode := IdentityDictionary new.
		boundsByShape keysAndValuesDo: [ :aShape :proposedBounds |
			boundsByFlowNode
				at: (processDiagramContext modelElementOf: aShape)
				put: proposedBounds ].
		modelElements size = 1 ifTrue: [
			^ CPAtelierTransferFlowNode
				flowNode: modelElements anyOne
				targetContainer: aTargetContainer
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
			targetContainer: aTargetContainer
			boundsByFlowNode: boundsByFlowNode
			waypointsBySequenceFlow: waypointsBySequenceFlow
			processMemento: processMemento
			diagramDescription: diagramDescription ].

	boundsByShape size = 1 ifTrue: [
		^ CPAtelierMoveShape
			shape: boundsByShape keys anyOne
			bounds: boundsByShape values anyOne
			processMemento: processMemento
			diagramDescription: diagramDescription ].
	^ CPAtelierMoveShapes
		boundsByShape: boundsByShape
		processMemento: processMemento
		diagramDescription: diagramDescription
]

{ #category : 'private - staged state' }
CPProcessAtelierDiagramEditing >> processDiagramContext [
	| diagram diagramMemento elementsDescription |
	diagram := processMemento readUsing: diagramDescription.
	diagramMemento := processMemento childMementoFor: diagram inRelation: diagramDescription.
	elementsDescription := diagramMemento magritteDescription
		detect: [ :each | each handlesSelector: #elements ].
	^ CPDiagramMementoContext
		diagram: diagram
		memento: diagramMemento
		elementsDescription: elementsDescription
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
CPProcessAtelierDiagramEditing >> replaceFlowNode: aFlowNode with: aReplacementNode bounds: proposedBounds flowContainer: aFlowContainer [
	^ CPAtelierReplaceFlowNode
		flowNode: aFlowNode
		with: aReplacementNode
		bounds: proposedBounds
		flowContainer: aFlowContainer
		processMemento: processMemento
		diagramDescription: diagramDescription
]

{ #category : 'operation factories' }
CPProcessAtelierDiagramEditing >> connectFrom: aSourceShape to: aTargetShape waypoints: someWaypoints [
	| source target sourceContainer targetContainer |
	source := self modelElementOfShape: aSourceShape.
	target := self modelElementOfShape: aTargetShape.
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
CPProcessAtelierDiagramEditing >> modelElementOfShape: aShape [
	| collaborationContext collaborationDiagramContext processDiagramContext |
	collaborationContext := CPProcessCollaborationContext inRootMemento: processMemento.
	(collaborationContext notNil
		and: [ collaborationContext elements identityIncludes: aShape ]) ifTrue: [
		collaborationDiagramContext := CPDiagramMementoContext
			diagram: collaborationContext diagram
			memento: collaborationContext diagramMemento
			elementsDescription: collaborationContext elementsDescription.
		^ collaborationDiagramContext modelElementOf: aShape ].
	processDiagramContext := self processDiagramContext.
	(processDiagramContext elements identityIncludes: aShape) ifTrue: [
		^ processDiagramContext modelElementOf: aShape ].
	^ nil
]

{ #category : 'operation factories' }
CPProcessAtelierDiagramEditing >> insertFlowNode: aFlowNode intoSequenceFlow: aSequenceFlow bounds: proposedBounds flowContainer: aFlowContainer [
	^ CPAtelierInsertFlowNode
		sequenceFlow: aSequenceFlow
		flowNode: aFlowNode
		bounds: proposedBounds
		flowContainer: aFlowContainer
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
CPProcessAtelierDiagramEditing >> reconnectSequenceFlow: aSequenceFlow source: aSource target: aTarget flowContainer: aFlowContainer [
	^ CPAtelierReconnectSequenceFlow
		sequenceFlow: aSequenceFlow
		source: aSource
		target: aTarget
		flowContainer: aFlowContainer
		processMemento: processMemento
		diagramDescription: diagramDescription
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
	^ CPAtelierSetEdgeWaypoints
		edge: anEdge
		waypoints: someWaypoints
		processMemento: processMemento
		diagramDescription: diagramDescription
]

{ #category : 'operation factories' }
CPProcessAtelierDiagramEditing >> setLabelSegmentIndex: aSegmentIndex segmentPosition: aSegmentPosition offset: anOffset forEdge: anEdge [
	^ CPAtelierSetEdgeLabelPlacement
		edge: anEdge
		segmentIndex: aSegmentIndex
		segmentPosition: aSegmentPosition
		offset: anOffset
		processMemento: processMemento
		diagramDescription: diagramDescription
]

