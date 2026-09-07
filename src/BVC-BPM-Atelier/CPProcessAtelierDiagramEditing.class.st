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
CPProcessAtelierDiagramEditing >> createParticipant: aParticipant bounds: proposedBounds [
	^ CPAtelierCreateParticipant
		participant: aParticipant
		bounds: proposedBounds
		processMemento: processMemento
]


{ #category : 'operation factories' }
CPProcessAtelierDiagramEditing >> moveShapes: boundsByShape toProcessHostedBy: aHostShape waypointsByEdge: waypointsByEdge [
	| collaborationContext processDiagramContext modelElements currentContainers targetContainer boundsByFlowNode waypointsBySequenceFlow |
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
	modelElements := boundsByShape keys collect: [ :aShape |
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
		boundsByShape keysAndValuesDo: [ :aShape :proposedBounds |
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
	| diagram |
	diagram := processMemento readUsing: diagramDescription.
	^ CPDiagramMementoContext
		diagram: diagram
		inMemento: processMemento
		using: diagramDescription
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
CPProcessAtelierDiagramEditing >> reconnectEdge: anEdge sourceShape: aSourceShape targetShape: aTargetShape [
	| sequenceFlow source target flowContainer |
	sequenceFlow := self modelElementOfDiagramElement: anEdge.
	source := self modelElementOfDiagramElement: aSourceShape.
	target := self modelElementOfDiagramElement: aTargetShape.
	(sequenceFlow isNil or: [ source isNil or: [ target isNil ] ]) ifTrue: [ ^ nil ].
	flowContainer := self flowContainerContaining: sequenceFlow.
	flowContainer ifNil: [ ^ nil ].
	^ CPAtelierReconnectSequenceFlow
		sequenceFlow: sequenceFlow
		source: source
		target: target
		flowContainer: flowContainer
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

