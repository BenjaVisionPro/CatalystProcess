"I describe how resources are assigned to a BPMN Activity. A role uses either a Resource reference or a ResourceAssignmentExpression; parameter bindings apply only to a referenced Resource."
Class {
	#name : 'CPResourceRole',
	#superclass : 'CFIdentifiableObject',
	#instVars : [ 'resourceRef', 'resourceAssignmentExpression', 'resourceParameterBindings' ],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}
{ #category : 'initialization' }
CPResourceRole >> initialize [ super initialize. resourceParameterBindings := OrderedCollection new ]
{ #category : 'accessing' }
CPResourceRole >> resourceRef [ ^ resourceRef ]
{ #category : 'accessing' }
CPResourceRole >> resourceRef: aResource [ resourceRef := aResource ]
{ #category : 'accessing' }
CPResourceRole >> resourceAssignmentExpression [ ^ resourceAssignmentExpression ]
{ #category : 'accessing' }
CPResourceRole >> resourceAssignmentExpression: anAssignmentExpression [ resourceAssignmentExpression := anAssignmentExpression ]
{ #category : 'accessing' }
CPResourceRole >> resourceParameterBindings [ ^ resourceParameterBindings ]
{ #category : 'accessing' }
CPResourceRole >> resourceParameterBindings: aCollection [ resourceParameterBindings := aCollection asOrderedCollection ]
{ #category : 'validation' }
CPResourceRole >> hasValidAssignment [
	(resourceRef notNil and: [ resourceAssignmentExpression notNil ]) ifTrue: [ ^ false ].
	(resourceParameterBindings notEmpty and: [ resourceRef isNil ]) ifTrue: [ ^ false ].
	^ true
]
{ #category : 'descriptions' }
CPResourceRole >> resourceRefDescription [ <magritteDescription> ^ MAToOneRelationDescription new accessor: #resourceRef; classes: { CPResource }; reference: CPResource new labelDescription; label: 'Resource'; priority: 100; group: 'Assignment'; yourself ]
{ #category : 'descriptions' }
CPResourceRole >> resourceAssignmentExpressionDescription [ <magritteDescription> ^ MAToOneRelationDescription new accessor: #resourceAssignmentExpression; classes: { CPResourceAssignmentExpression }; reference: CPResourceAssignmentExpression new identifierDescription; label: 'Assignment expression'; priority: 110; group: 'Assignment'; yourself ]
{ #category : 'descriptions' }
CPResourceRole >> resourceParameterBindingsDescription [ <magritteDescription> ^ MAToManyRelationDescription new accessor: #resourceParameterBindings; classes: { CPResourceParameterBinding }; reference: CPResourceParameterBinding new identifierDescription; label: 'Parameter bindings'; priority: 120; group: 'Assignment'; beOrdered; yourself ]

{ #category : 'testing' }
CPResourceRole >> isPotentialOwner [ ^ false ]

{ #category : 'testing' }
CPResourceRole >> usesResourceAssignmentExpression [
	^ resourceAssignmentExpression notNil
]

{ #category : 'testing' }
CPResourceRole >> usesResourceReference [
	^ resourceRef notNil
]
