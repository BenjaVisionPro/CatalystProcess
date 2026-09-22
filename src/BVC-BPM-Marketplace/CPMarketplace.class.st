"I am the Marketplace belonging to one Catalyst Process installation. I make immutable published Definitions available to that installation. BPMN execution and Catalyst Runtime do not depend on me."
Class {
	#name : 'CPMarketplace',
	#superclass : 'CFLabelledObject',
	#instVars : [
		'publishedDefinitions'
	],
	#category : 'BVC-BPM-Marketplace-Domain',
	#package : 'BVC-BPM-Marketplace',
	#tag : 'Domain'
}

{ #category : 'initialization' }
CPMarketplace >> initialize [
	super initialize.
	publishedDefinitions := OrderedCollection new
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
