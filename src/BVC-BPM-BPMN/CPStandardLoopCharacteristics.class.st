"I represent BPMN standard looping: repeat an Activity while a condition holds, optionally testing before the iteration and limiting the number of iterations."
Class {
	#name : 'CPStandardLoopCharacteristics',
	#superclass : 'CPLoopCharacteristics',
	#instVars : [ 'testBefore', 'loopMaximum', 'loopCondition' ],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'initialization' }
CPStandardLoopCharacteristics >> initialize [ super initialize. testBefore := false ]
{ #category : 'accessing' }
CPStandardLoopCharacteristics >> testBefore [ ^ testBefore ]
{ #category : 'accessing' }
CPStandardLoopCharacteristics >> testBefore: aBoolean [ testBefore := aBoolean ]
{ #category : 'accessing' }
CPStandardLoopCharacteristics >> loopMaximum [ ^ loopMaximum ]
{ #category : 'accessing' }
CPStandardLoopCharacteristics >> loopMaximum: anInteger [ loopMaximum := anInteger ]
{ #category : 'accessing' }
CPStandardLoopCharacteristics >> loopCondition [ ^ loopCondition ]
{ #category : 'accessing' }
CPStandardLoopCharacteristics >> loopCondition: anExpression [ loopCondition := anExpression ]
{ #category : 'descriptions' }
CPStandardLoopCharacteristics >> testBeforeDescription [ <magritteDescription> ^ MABooleanDescription new accessor: #testBefore; label: 'Test before'; priority: 100; group: 'Loop'; yourself ]
{ #category : 'descriptions' }
CPStandardLoopCharacteristics >> loopMaximumDescription [ <magritteDescription> ^ MANumberDescription new accessor: #loopMaximum; label: 'Maximum iterations'; priority: 110; group: 'Loop'; yourself ]
{ #category : 'descriptions' }
CPStandardLoopCharacteristics >> loopConditionDescription [ <magritteDescription> ^ MAToOneRelationDescription new accessor: #loopCondition; classes: { CPExpression }; reference: CPExpression new identifierDescription; label: 'Loop condition'; priority: 120; group: 'Loop'; yourself ]
