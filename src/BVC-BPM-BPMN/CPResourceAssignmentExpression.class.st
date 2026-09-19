Class {
	#name : 'CPResourceAssignmentExpression',
	#superclass : 'CFIdentifiableObject',
	#instVars : [ 'expression' ],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}
{ #category : 'accessing' }
CPResourceAssignmentExpression >> expression [ ^ expression ]
{ #category : 'accessing' }
CPResourceAssignmentExpression >> expression: anExpression [ expression := anExpression ]
{ #category : 'descriptions' }
CPResourceAssignmentExpression >> expressionDescription [ <magritteDescription> ^ MAToOneRelationDescription new accessor: #expression; classes: { CPExpression }; reference: CPExpression new identifierDescription; label: 'Expression'; priority: 100; group: 'Assignment'; beRequired; yourself ]
