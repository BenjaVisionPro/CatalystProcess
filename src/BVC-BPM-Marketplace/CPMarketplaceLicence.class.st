"I authorize one Tenant to use a Marketplace product through an explicit set of licensed features for a stated period. I describe Marketplace authorization; BPMN execution and Catalyst Runtime do not depend on me."
Class {
	#name : 'CPMarketplaceLicence',
	#superclass : 'CFLabelledObject',
	#instVars : [
		'tenant',
		'product',
		'features',
		'effectiveFrom',
		'effectiveUntil'
	],
	#category : 'BVC-BPM-Marketplace-Domain',
	#package : 'BVC-BPM-Marketplace',
	#tag : 'Domain'
}

{ #category : 'initialization' }
CPMarketplaceLicence >> initialize [
	super initialize.
	features := OrderedCollection new
]

{ #category : 'accessing' }
CPMarketplaceLicence >> tenant [ ^ tenant ]

{ #category : 'accessing' }
CPMarketplaceLicence >> tenant: aTenant [ tenant := aTenant ]

{ #category : 'accessing' }
CPMarketplaceLicence >> product [ ^ product ]

{ #category : 'accessing' }
CPMarketplaceLicence >> product: aProduct [ product := aProduct ]

{ #category : 'accessing' }
CPMarketplaceLicence >> features [ ^ features ]

{ #category : 'adding' }
CPMarketplaceLicence >> addFeature: aFeature [
	aFeature ifNil: [ self error: 'A licensed feature is required.' ].
	(features anySatisfy: [ :each | each class = aFeature class ]) ifFalse: [
		features add: aFeature ].
	^ aFeature
]

{ #category : 'testing' }
CPMarketplaceLicence >> includesFeature: aFeature [
	^ features anySatisfy: [ :each | each class = aFeature class ]
]

{ #category : 'accessing' }
CPMarketplaceLicence >> effectiveFrom [ ^ effectiveFrom ]

{ #category : 'accessing' }
CPMarketplaceLicence >> effectiveFrom: aDateAndTime [ effectiveFrom := aDateAndTime ]

{ #category : 'accessing' }
CPMarketplaceLicence >> effectiveUntil [ ^ effectiveUntil ]

{ #category : 'accessing' }
CPMarketplaceLicence >> effectiveUntil: aDateAndTime [ effectiveUntil := aDateAndTime ]

{ #category : 'testing' }
CPMarketplaceLicence >> isEffectiveAt: aDateAndTime [
	^ (effectiveFrom isNil or: [ aDateAndTime >= effectiveFrom ])
		and: [ effectiveUntil isNil or: [ aDateAndTime <= effectiveUntil ] ]
]

{ #category : 'testing' }
CPMarketplaceLicence >> authorizesFeature: aFeature at: aDateAndTime [
	^ (self isEffectiveAt: aDateAndTime)
		and: [ self includesFeature: aFeature ]
]

{ #category : 'descriptions' }
CPMarketplaceLicence >> tenantDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #tenant;
		label: 'Tenant';
		priority: 10;
		group: 'Relations';
		yourself
]

{ #category : 'descriptions' }
CPMarketplaceLicence >> productDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #product;
		label: 'Product';
		priority: 20;
		group: 'Relations';
		yourself
]

{ #category : 'descriptions' }
CPMarketplaceLicence >> featuresDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #features;
		label: 'Licensed Features';
		priority: 30;
		group: 'Relations';
		yourself
]
