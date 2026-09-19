"I represent a BPMN Resource definition. Runtime resolution of actual users, groups, roles or other resources belongs to the execution environment."
Class {
	#name : 'CPResource',
	#superclass : 'CFLabelledObject',
	#instVars : [ 'resourceParameters' ],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'initialization' }
CPResource >> initialize [ super initialize. resourceParameters := OrderedCollection new ]
{ #category : 'accessing' }
CPResource >> resourceParameters [ ^ resourceParameters ]
{ #category : 'accessing' }
CPResource >> resourceParameters: aCollection [ resourceParameters := aCollection asOrderedCollection ]
{ #category : 'adding' }
CPResource >> addResourceParameter: aParameter [ (resourceParameters identityIncludes: aParameter) ifFalse: [ resourceParameters add: aParameter ] ]
{ #category : 'removing' }
CPResource >> removeResourceParameter: aParameter [ resourceParameters remove: aParameter ifAbsent: [ ] ]
{ #category : 'descriptions' }
CPResource >> resourceParametersDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new accessor: #resourceParameters; classes: { CPResourceParameter }; reference: CPResourceParameter new labelDescription; label: 'Parameters'; priority: 100; group: 'Relations'; beModifiable; beOrdered; newItemClassStencil: [ :aClass | aClass new ]; yourself
]
{ #category : 'accessing - presentation' }
CPResource class >> defaultIcon [ ^ #users ]
