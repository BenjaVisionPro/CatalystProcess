Class {
	#name : 'CPTenant',
	#superclass : 'CFLabelledObject',
	#instVars : [
		'comment',
		'memberships',
		'processDesigns',
		'processDeployments'
	],
	#category : 'BVC-BPM-Core',
	#package : 'BVC-BPM-Core'
}

{ #category : 'accessing' }
CPTenant >> comment [
	^ comment
]

{ #category : 'accessing' }
CPTenant >> comment: anObject [
	comment := anObject
]

{ #category : 'accessing' }
CPTenant >> memberships [
	^ memberships
]

{ #category : 'accessing' }
CPTenant >> memberships: anObject [
	memberships := anObject
]

{ #category : 'accessing' }
CPTenant >> processDesigns [
	^ processDesigns
]

{ #category : 'accessing' }
CPTenant >> processDesigns: anObject [
	processDesigns := anObject
]

{ #category : 'accessing' }
CPTenant >> processDeployments [
	^ processDeployments
]

{ #category : 'accessing' }
CPTenant >> processDeployments: anObject [
	processDeployments := anObject
]

{ #category : 'initialization' }
CPTenant >> initialize [
	super initialize.
	memberships := OrderedCollection new.
	processDesigns := OrderedCollection new.
	processDeployments := OrderedCollection new
]

{ #category : 'descriptions' }
CPTenant >> commentDescription [
	<magritteDescription>
	^ MAMemoDescription new
		accessor: #comment;
		label: 'Comment';
		priority: 100;
		group: 'General';
		yourself
]

{ #category : 'descriptions' }
CPTenant >> membershipsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #memberships;
		label: 'Memberships';
		priority: 110;
		group: 'Relations';
		yourself
]

{ #category : 'descriptions' }
CPTenant >> processDesignsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #processDesigns;
		label: 'Processdesigns';
		priority: 110;
		group: 'Relations';
		yourself
]

{ #category : 'descriptions' }
CPTenant >> processDeploymentsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #processDeployments;
		label: 'Processdeployments';
		priority: 110;
		group: 'Relations';
		yourself
]

