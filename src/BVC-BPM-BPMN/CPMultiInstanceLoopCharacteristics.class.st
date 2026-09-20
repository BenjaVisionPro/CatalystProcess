"I represent BPMN multi-instance looping. I describe how Activity instances are generated and completed; runtime instance counts belong to execution state."
Class {
	#name : 'CPMultiInstanceLoopCharacteristics',
	#superclass : 'CPLoopCharacteristics',
	#instVars : [ 'isSequential', 'loopCardinality', 'loopDataInputRef', 'loopDataOutputRef', 'inputDataItem', 'outputDataItem', 'behavior', 'complexBehaviorDefinitions', 'completionCondition', 'oneBehaviorEventRef', 'noneBehaviorEventRef' ],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'initialization' }
CPMultiInstanceLoopCharacteristics >> initialize [ super initialize. isSequential := false. behavior := 'All'. complexBehaviorDefinitions := OrderedCollection new ]
{ #category : 'accessing' }
CPMultiInstanceLoopCharacteristics >> isSequential [ ^ isSequential ]
{ #category : 'accessing' }
CPMultiInstanceLoopCharacteristics >> isSequential: aBoolean [ isSequential := aBoolean ]
{ #category : 'accessing' }
CPMultiInstanceLoopCharacteristics >> loopCardinality [ ^ loopCardinality ]
{ #category : 'accessing' }
CPMultiInstanceLoopCharacteristics >> loopCardinality: anExpression [ loopCardinality := anExpression ]
{ #category : 'accessing' }
CPMultiInstanceLoopCharacteristics >> loopDataInputRef [ ^ loopDataInputRef ]
{ #category : 'accessing' }
CPMultiInstanceLoopCharacteristics >> loopDataInputRef: anItemAwareElement [ loopDataInputRef := anItemAwareElement ]
{ #category : 'accessing' }
CPMultiInstanceLoopCharacteristics >> loopDataOutputRef [ ^ loopDataOutputRef ]
{ #category : 'accessing' }
CPMultiInstanceLoopCharacteristics >> loopDataOutputRef: anItemAwareElement [ loopDataOutputRef := anItemAwareElement ]
{ #category : 'accessing' }
CPMultiInstanceLoopCharacteristics >> inputDataItem [ ^ inputDataItem ]
{ #category : 'accessing' }
CPMultiInstanceLoopCharacteristics >> inputDataItem: aDataInput [ inputDataItem := aDataInput ]
{ #category : 'accessing' }
CPMultiInstanceLoopCharacteristics >> outputDataItem [ ^ outputDataItem ]
{ #category : 'accessing' }
CPMultiInstanceLoopCharacteristics >> outputDataItem: aDataOutput [ outputDataItem := aDataOutput ]
{ #category : 'accessing' }
CPMultiInstanceLoopCharacteristics >> behavior [ ^ behavior ]
{ #category : 'accessing' }
CPMultiInstanceLoopCharacteristics >> behavior: aString [ behavior := aString ]
{ #category : 'configuring' }
CPMultiInstanceLoopCharacteristics >> beAll [ behavior := 'All' ]
{ #category : 'configuring' }
CPMultiInstanceLoopCharacteristics >> beNone [ behavior := 'None' ]
{ #category : 'configuring' }
CPMultiInstanceLoopCharacteristics >> beOne [ behavior := 'One' ]
{ #category : 'configuring' }
CPMultiInstanceLoopCharacteristics >> beComplex [ behavior := 'Complex' ]
{ #category : 'accessing' }
CPMultiInstanceLoopCharacteristics >> complexBehaviorDefinitions [ ^ complexBehaviorDefinitions ]
{ #category : 'accessing' }
CPMultiInstanceLoopCharacteristics >> complexBehaviorDefinitions: aCollection [ complexBehaviorDefinitions := aCollection asOrderedCollection ]
{ #category : 'accessing' }
CPMultiInstanceLoopCharacteristics >> completionCondition [ ^ completionCondition ]
{ #category : 'accessing' }
CPMultiInstanceLoopCharacteristics >> completionCondition: anExpression [ completionCondition := anExpression ]
{ #category : 'accessing' }
CPMultiInstanceLoopCharacteristics >> oneBehaviorEventRef [ ^ oneBehaviorEventRef ]
{ #category : 'accessing' }
CPMultiInstanceLoopCharacteristics >> oneBehaviorEventRef: anEventDefinition [ oneBehaviorEventRef := anEventDefinition ]
{ #category : 'accessing' }
CPMultiInstanceLoopCharacteristics >> noneBehaviorEventRef [ ^ noneBehaviorEventRef ]
{ #category : 'accessing' }
CPMultiInstanceLoopCharacteristics >> noneBehaviorEventRef: anEventDefinition [ noneBehaviorEventRef := anEventDefinition ]
{ #category : 'descriptions' }
CPMultiInstanceLoopCharacteristics >> isSequentialDescription [ <magritteDescription> ^ MABooleanDescription new accessor: #isSequential; label: 'Sequential'; priority: 100; group: 'Multi-instance'; yourself ]
{ #category : 'descriptions' }
CPMultiInstanceLoopCharacteristics >> loopCardinalityDescription [ <magritteDescription> ^ MAToOneRelationDescription new accessor: #loopCardinality; classes: { CPExpression }; reference: CPExpression new identifierDescription; label: 'Loop cardinality'; priority: 110; group: 'Multi-instance'; yourself ]
{ #category : 'descriptions' }
CPMultiInstanceLoopCharacteristics >> loopDataInputRefDescription [ <magritteDescription> ^ MAToOneRelationDescription new accessor: #loopDataInputRef; classes: { CPItemAwareElement }; reference: CPItemAwareElement new identifierDescription; label: 'Loop data input'; priority: 120; group: 'Multi-instance'; yourself ]
{ #category : 'descriptions' }
CPMultiInstanceLoopCharacteristics >> loopDataOutputRefDescription [ <magritteDescription> ^ MAToOneRelationDescription new accessor: #loopDataOutputRef; classes: { CPItemAwareElement }; reference: CPItemAwareElement new identifierDescription; label: 'Loop data output'; priority: 130; group: 'Multi-instance'; yourself ]
{ #category : 'descriptions' }
CPMultiInstanceLoopCharacteristics >> inputDataItemDescription [ <magritteDescription> ^ MAToOneRelationDescription new accessor: #inputDataItem; classes: { CPDataInput }; reference: CPDataInput new identifierDescription; label: 'Input data item'; priority: 140; group: 'Multi-instance'; yourself ]
{ #category : 'descriptions' }
CPMultiInstanceLoopCharacteristics >> outputDataItemDescription [ <magritteDescription> ^ MAToOneRelationDescription new accessor: #outputDataItem; classes: { CPDataOutput }; reference: CPDataOutput new identifierDescription; label: 'Output data item'; priority: 150; group: 'Multi-instance'; yourself ]
{ #category : 'descriptions' }
CPMultiInstanceLoopCharacteristics >> behaviorDescription [ <magritteDescription> ^ MASingleOptionDescription new accessor: #behavior; label: 'Behavior'; options: { 'None'. 'One'. 'All'. 'Complex' }; priority: 160; group: 'Multi-instance'; yourself ]
{ #category : 'descriptions' }
CPMultiInstanceLoopCharacteristics >> complexBehaviorDefinitionsDescription [ <magritteDescription> ^ MAToManyRelationDescription new accessor: #complexBehaviorDefinitions; classes: { CPComplexBehaviorDefinition }; reference: CPComplexBehaviorDefinition new identifierDescription; label: 'Complex behaviors'; priority: 170; group: 'Multi-instance'; beOrdered; yourself ]
{ #category : 'descriptions' }
CPMultiInstanceLoopCharacteristics >> completionConditionDescription [ <magritteDescription> ^ MAToOneRelationDescription new accessor: #completionCondition; classes: { CPExpression }; reference: CPExpression new identifierDescription; label: 'Completion condition'; priority: 180; group: 'Multi-instance'; yourself ]
{ #category : 'descriptions' }
CPMultiInstanceLoopCharacteristics >> oneBehaviorEventRefDescription [ <magritteDescription> ^ MAToOneRelationDescription new accessor: #oneBehaviorEventRef; classes: { CPEventDefinition }; reference: CPEventDefinition new eventTypeLabelDescription; label: 'One behavior event'; priority: 190; group: 'Multi-instance'; yourself ]
{ #category : 'descriptions' }
CPMultiInstanceLoopCharacteristics >> noneBehaviorEventRefDescription [ <magritteDescription> ^ MAToOneRelationDescription new accessor: #noneBehaviorEventRef; classes: { CPEventDefinition }; reference: CPEventDefinition new eventTypeLabelDescription; label: 'None behavior event'; priority: 200; group: 'Multi-instance'; yourself ]


{ #category : 'testing' }
CPMultiInstanceLoopCharacteristics >> isMultiInstance [
	^ true
]
