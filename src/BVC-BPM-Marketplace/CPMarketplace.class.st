"I am the Marketplace belonging to one Catalyst Process installation. I make immutable published Definitions available to that installation. BPMN execution and Catalyst Runtime do not depend on me."
Class {
	#name : 'CPMarketplace',
	#superclass : 'CFLabelledObject',
	#instVars : [
		'publishedDefinitions',
		'products',
		'licences'
	],
	#category : 'BVC-BPM-Marketplace-Domain',
	#package : 'BVC-BPM-Marketplace',
	#tag : 'Domain'
}

{ #category : 'initialization' }
CPMarketplace >> initialize [
	super initialize.
	publishedDefinitions := OrderedCollection new.
	products := OrderedCollection new.
	licences := OrderedCollection new
]

{ #category : 'accessing' }
CPMarketplace >> publishedDefinitions [
	^ publishedDefinitions
]

{ #category : 'adding' }
CPMarketplace >> addPublishedDefinition: aDefinitionSourceClass [
	(CPDefinitionsSourceMaterializer isPublishedVersion: aDefinitionSourceClass) ifFalse: [
		self error: 'A Marketplace Definition must be an immutable published Definition version.' ].
	(publishedDefinitions identityIncludes: aDefinitionSourceClass) ifFalse: [
		publishedDefinitions add: aDefinitionSourceClass ].
	^ aDefinitionSourceClass
]

{ #category : 'testing' }
CPMarketplace >> includesPublishedDefinition: aDefinitionSourceClass [
	^ publishedDefinitions identityIncludes: aDefinitionSourceClass
]

{ #category : 'descriptions' }
CPMarketplace >> publishedDefinitionsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #publishedDefinitions;
		label: 'Published Definitions';
		priority: 100;
		group: 'Relations';
		yourself
]


{ #category : 'accessing' }
CPMarketplace >> products [
	^ products
]

{ #category : 'adding' }
CPMarketplace >> addProduct: aProduct [
	aProduct ifNil: [ self error: 'A Marketplace product is required.' ].
	(products includes: aProduct) ifFalse: [ products add: aProduct ].
	^ aProduct
]

{ #category : 'descriptions' }
CPMarketplace >> productsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #products;
		label: 'Products';
		priority: 110;
		group: 'Relations';
		yourself
]


{ #category : 'accessing' }
CPMarketplace >> licences [
	^ licences
]

{ #category : 'adding' }
CPMarketplace >> addLicence: aLicence [
	aLicence ifNil: [ self error: 'A Marketplace licence is required.' ].
	(licences includes: aLicence) ifFalse: [ licences add: aLicence ].
	^ aLicence
]

{ #category : 'descriptions' }
CPMarketplace >> licencesDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #licences;
		label: 'Licences';
		priority: 120;
		group: 'Relations';
		yourself
]
