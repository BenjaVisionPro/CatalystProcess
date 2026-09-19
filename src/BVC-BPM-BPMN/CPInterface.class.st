"I define a BPMN service interface and structurally contain its Operations."
Class {
	#name : 'CPInterface',
	#superclass : 'CFLabelledObject',
	#instVars : [ 'operations', 'implementationRef' ],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}
{ #category : 'initialization' }
CPInterface >> initialize [ super initialize. operations := OrderedCollection new ]
{ #category : 'accessing' }
CPInterface >> operations [ ^ operations ]
{ #category : 'accessing' }
CPInterface >> operations: aCollection [ operations := aCollection asOrderedCollection ]
{ #category : 'adding' }
CPInterface >> addOperation: anOperation [ (operations identityIncludes: anOperation) ifFalse: [ operations add: anOperation ] ]
{ #category : 'removing' }
CPInterface >> removeOperation: anOperation [ operations remove: anOperation ifAbsent: [ ] ]
{ #category : 'accessing' }
CPInterface >> implementationRef [ ^ implementationRef ]
{ #category : 'accessing' }
CPInterface >> implementationRef: anObject [ implementationRef := anObject ]
{ #category : 'descriptions' }
CPInterface >> operationsDescription [ <magritteDescription> ^ MAToManyRelationDescription new accessor: #operations; classes: { CPOperation }; reference: CPOperation new labelDescription; label: 'Operations'; priority: 100; group: 'Relations'; beModifiable; beOrdered; newItemClassStencil: [ :aClass | aClass new ]; beRequired; yourself ]
{ #category : 'accessing - presentation' }
CPInterface class >> defaultIcon [ ^ #plug ]
