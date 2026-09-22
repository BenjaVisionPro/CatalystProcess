"I am a Marketplace product. I package immutable published Definitions without owning their publication lifecycle."
Class {
	#name : 'CPMarketplaceProduct',
	#superclass : 'CFLabelledObject',
	#instVars : [
		'publishedDefinitions'
	],
	#category : 'BVC-BPM-Marketplace-Domain',
	#package : 'BVC-BPM-Marketplace',
	#tag : 'Domain'
}

{ #category : 'initialization' }
CPMarketplaceProduct >> initialize [
	super initialize.
	publishedDefinitions := OrderedCollection new
]

{ #category : 'accessing' }
CPMarketplaceProduct >> publishedDefinitions [
	^ publishedDefinitions
]

{ #category : 'adding' }
CPMarketplaceProduct >> addPublishedDefinition: aDefinitionSourceClass [
	(CPDefinitionsSourceMaterializer isPublishedVersion: aDefinitionSourceClass) ifFalse: [
		self error: 'A Marketplace product can contain only immutable published Definition versions.' ].
	(publishedDefinitions identityIncludes: aDefinitionSourceClass) ifFalse: [
		publishedDefinitions add: aDefinitionSourceClass ].
	^ aDefinitionSourceClass
]

{ #category : 'testing' }
CPMarketplaceProduct >> includesPublishedDefinition: aDefinitionSourceClass [
	^ publishedDefinitions identityIncludes: aDefinitionSourceClass
]

{ #category : 'descriptions' }
CPMarketplaceProduct >> publishedDefinitionsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #publishedDefinitions;
		label: 'Published Definitions';
		priority: 100;
		group: 'Relations';
		yourself
]
