"I represent one BPMN Lane within a LaneSet.

I partition FlowNodes by reference; I do not own those FlowNodes. I may own one child LaneSet for nested Lanes. My owning LaneSet is maintained by CPLaneSet."
Class {
	#name : 'CPLane',
	#superclass : 'CFLabelledObject',
	#instVars : [
		'laneSet',
		'flowNodeRefs',
		'childLaneSet',
		'partitionElement',
		'partitionElementRef'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'initialization' }
CPLane >> initialize [
	super initialize.
	flowNodeRefs := OrderedCollection new
]

{ #category : 'accessing' }
CPLane >> laneSet [
	^ laneSet
]

{ #category : 'accessing' }
CPLane >> laneSet: aLaneSet [
	laneSet := aLaneSet
]

{ #category : 'accessing' }
CPLane >> flowNodeRefs [
	^ flowNodeRefs
]

{ #category : 'accessing' }
CPLane >> flowNodeRefs: aCollection [
	flowNodeRefs := aCollection asOrderedCollection
]

{ #category : 'adding' }
CPLane >> addFlowNodeRef: aFlowNode [
	(flowNodeRefs identityIncludes: aFlowNode) ifFalse: [
		flowNodeRefs add: aFlowNode ]
]

{ #category : 'removing' }
CPLane >> removeFlowNodeRef: aFlowNode [
	flowNodeRefs remove: aFlowNode ifAbsent: [ ]
]

{ #category : 'accessing' }
CPLane >> childLaneSet [
	^ childLaneSet
]

{ #category : 'accessing' }
CPLane >> childLaneSet: aLaneSet [
	childLaneSet == aLaneSet ifTrue: [ ^ self ].
	childLaneSet ifNotNil: [ :aPreviousLaneSet |
		aPreviousLaneSet parentLane == self ifTrue: [
			aPreviousLaneSet parentLane: nil ] ].
	childLaneSet := aLaneSet.
	childLaneSet ifNotNil: [ :aChildLaneSet |
		aChildLaneSet parentLane: self ]
]

{ #category : 'accessing' }
CPLane >> partitionElement [
	^ partitionElement
]

{ #category : 'accessing' }
CPLane >> partitionElement: aBaseElement [
	partitionElement := aBaseElement
]

{ #category : 'accessing' }
CPLane >> partitionElementRef [
	^ partitionElementRef
]

{ #category : 'accessing' }
CPLane >> partitionElementRef: aBaseElement [
	partitionElementRef := aBaseElement
]

{ #category : 'descriptions' }
CPLane >> flowNodeRefsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #flowNodeRefs;
		classes: { CPFlowNode };
		reference: CPFlowNode new labelDescription;
		label: 'Flow nodes';
		priority: 100;
		group: 'Relations';
		yourself
]

{ #category : 'descriptions' }
CPLane >> childLaneSetDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #childLaneSet;
		classes: { CPLaneSet };
		reference: CPLaneSet new labelDescription;
		label: 'Child lane set';
		priority: 110;
		group: 'Relations';
		yourself
]
