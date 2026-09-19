Class {
	#name : 'CPResourceParameterBinding',
	#superclass : 'CFIdentifiableObject',
	#instVars : [ 'parameterRef', 'expression' ],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}
{ #category : 'accessing' }
CPResourceParameterBinding >> parameterRef [ ^ parameterRef ]
{ #category : 'accessing' }
CPResourceParameterBinding >> parameterRef: aParameter [ parameterRef := aParameter ]
{ #category : 'accessing' }
CPResourceParameterBinding >> expression [ ^ expression ]
{ #category : 'accessing' }
CPResourceParameterBinding >> expression: anExpression [ expression := anExpression ]
{ #category : 'descriptions' }
CPResourceParameterBinding >> parameterRefDescription [ <magritteDescription> ^ MAToOneRelationDescription new accessor: #parameterRef; classes: { CPResourceParameter }; reference: CPResourceParameter new labelDescription; label: 'Parameter'; priority: 100; group: 'Binding'; beRequired; yourself ]
{ #category : 'descriptions' }
CPResourceParameterBinding >> expressionDescription [ <magritteDescription> ^ MAToOneRelationDescription new accessor: #expression; classes: { CPExpression }; reference: CPExpression new identifierDescription; label: 'Expression'; priority: 110; group: 'Binding'; beRequired; yourself ]
