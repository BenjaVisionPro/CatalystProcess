"I represent a BPMN LaneSet.

I am a semantic partition owned either directly by a Process or as the child LaneSet of one Lane. I am not itself displayed in BPMN DI; my Lanes are the displayed partitions."
Class {
	#name : 'CPLaneSet',
	#superclass : 'CFLabelledObject',
	#instVars : [
		'lanes',
		'process',
		'parentLane'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'initialization' }
CPLaneSet >> initialize [
	super initialize.
	lanes := OrderedCollection new
]

{ #category : 'accessing' }
CPLaneSet >> lanes [
	^ lanes
]

{ #category : 'accessing' }
CPLaneSet >> lanes: aCollection [
	lanes copy do: [ :each | self removeLane: each ].
	aCollection do: [ :each | self addLane: each ]
]

{ #category : 'adding' }
CPLaneSet >> addLane: aLane [
	(lanes identityIncludes: aLane) ifTrue: [ ^ self ].
	lanes add: aLane.
	aLane laneSet: self
]

{ #category : 'removing' }
CPLaneSet >> removeLane: aLane [
	(lanes identityIncludes: aLane) ifFalse: [ ^ self ].
	lanes remove: aLane.
	aLane laneSet == self ifTrue: [ aLane laneSet: nil ]
]

{ #category : 'accessing' }
CPLaneSet >> process [
	^ process
]

{ #category : 'accessing' }
CPLaneSet >> process: aProcess [
	process := aProcess
]

{ #category : 'accessing' }
CPLaneSet >> parentLane [
	^ parentLane
]

{ #category : 'accessing' }
CPLaneSet >> parentLane: aLane [
	parentLane := aLane
]

{ #category : 'descriptions' }
CPLaneSet >> lanesDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #lanes;
		classes: { CPLane };
		reference: CPLane new labelDescription;
		label: 'Lanes';
		priority: 100;
		group: 'Relations';
		yourself
]

{ #category : 'descriptions' }
CPLaneSet >> processDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #process;
		classes: { CPProcess };
		reference: CPProcess new labelDescription;
		label: 'Process';
		priority: 110;
		group: 'Relations';
		beReadOnly;
		yourself
]

{ #category : 'descriptions' }
CPLaneSet >> parentLaneDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #parentLane;
		classes: { CPLane };
		reference: CPLane new labelDescription;
		label: 'Parent lane';
		priority: 120;
		group: 'Relations';
		beReadOnly;
		yourself
]
