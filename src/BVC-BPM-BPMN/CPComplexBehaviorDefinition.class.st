"I represent a BPMN ComplexBehaviorDefinition for a multi-instance Activity."
Class {
	#name : 'CPComplexBehaviorDefinition',
	#superclass : 'CFIdentifiableObject',
	#instVars : [ 'condition', 'event' ],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}
{ #category : 'accessing' }
CPComplexBehaviorDefinition >> condition [ ^ condition ]
{ #category : 'accessing' }
CPComplexBehaviorDefinition >> condition: aFormalExpression [ condition := aFormalExpression ]
{ #category : 'accessing' }
CPComplexBehaviorDefinition >> event [ ^ event ]
{ #category : 'accessing' }
CPComplexBehaviorDefinition >> event: anImplicitThrowEvent [ event := anImplicitThrowEvent ]
{ #category : 'descriptions' }
CPComplexBehaviorDefinition >> conditionDescription [ <magritteDescription> ^ MAToOneRelationDescription new accessor: #condition; classes: { CPFormalExpression }; reference: CPFormalExpression new identifierDescription; label: 'Condition'; priority: 100; group: 'Complex behavior'; beRequired; yourself ]
{ #category : 'descriptions' }
CPComplexBehaviorDefinition >> eventDescription [ <magritteDescription> ^ MAToOneRelationDescription new accessor: #event; classes: { CPImplicitThrowEvent }; reference: CPImplicitThrowEvent new identifierDescription; label: 'Event'; priority: 110; group: 'Complex behavior'; beRequired; yourself ]
