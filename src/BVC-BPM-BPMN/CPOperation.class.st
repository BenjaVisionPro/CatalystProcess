"I define the Messages consumed and optionally produced by one BPMN service operation, together with the Errors it may return."
Class {
	#name : 'CPOperation',
	#superclass : 'CFLabelledObject',
	#instVars : [ 'inMessageRef', 'outMessageRef', 'errorRefs', 'implementationRef' ],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}
{ #category : 'initialization' }
CPOperation >> initialize [ super initialize. errorRefs := OrderedCollection new ]
{ #category : 'accessing' }
CPOperation >> inMessageRef [ ^ inMessageRef ]
{ #category : 'accessing' }
CPOperation >> inMessageRef: aMessage [ inMessageRef := aMessage ]
{ #category : 'accessing' }
CPOperation >> outMessageRef [ ^ outMessageRef ]
{ #category : 'accessing' }
CPOperation >> outMessageRef: aMessage [ outMessageRef := aMessage ]
{ #category : 'accessing' }
CPOperation >> errorRefs [ ^ errorRefs ]
{ #category : 'accessing' }
CPOperation >> errorRefs: aCollection [ errorRefs := aCollection asOrderedCollection ]
{ #category : 'accessing' }
CPOperation >> implementationRef [ ^ implementationRef ]
{ #category : 'accessing' }
CPOperation >> implementationRef: anObject [ implementationRef := anObject ]
{ #category : 'descriptions' }
CPOperation >> inMessageRefDescription [ <magritteDescription> ^ MAToOneRelationDescription new accessor: #inMessageRef; classes: { CPMessage }; reference: CPMessage new labelDescription; label: 'Input message'; priority: 100; group: 'Relations'; beRequired; yourself ]
{ #category : 'descriptions' }
CPOperation >> outMessageRefDescription [ <magritteDescription> ^ MAToOneRelationDescription new accessor: #outMessageRef; classes: { CPMessage }; reference: CPMessage new labelDescription; label: 'Output message'; priority: 110; group: 'Relations'; yourself ]
{ #category : 'descriptions' }
CPOperation >> errorRefsDescription [ <magritteDescription> ^ MAToManyRelationDescription new accessor: #errorRefs; classes: { CPError }; reference: CPError new labelDescription; label: 'Errors'; priority: 120; group: 'Relations'; beOrdered; yourself ]
