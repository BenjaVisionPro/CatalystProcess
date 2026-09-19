Class {
	#name : 'CPGateway',
	#superclass : 'CPFlowNode',
	#instVars : [ 'gatewayDirection' ],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'testing' }
CPGateway >> isGateway [
	^ true
]

{ #category : 'gateway type' }
CPGateway class >> gatewayTypes [
	^ {
		CPExclusiveGateway.
		CPParallelGateway.
		CPInclusiveGateway.
		CPEventBasedGateway.
		CPComplexGateway
	}
]



{ #category : 'initialization' }
CPGateway >> initialize [ super initialize. gatewayDirection := 'Unspecified' ]
{ #category : 'accessing' }
CPGateway >> gatewayDirection [ ^ gatewayDirection ]
{ #category : 'accessing' }
CPGateway >> gatewayDirection: aString [ gatewayDirection := aString ]
{ #category : 'gateway direction' }
CPGateway >> beUnspecified [ gatewayDirection := 'Unspecified' ]
{ #category : 'gateway direction' }
CPGateway >> beConverging [ gatewayDirection := 'Converging' ]
{ #category : 'gateway direction' }
CPGateway >> beDiverging [ gatewayDirection := 'Diverging' ]
{ #category : 'gateway direction' }
CPGateway >> beMixed [ gatewayDirection := 'Mixed' ]
{ #category : 'validation' }
CPGateway >> hasValidGatewayDirection [
	(#('Unspecified' 'Converging' 'Diverging' 'Mixed') includes: gatewayDirection) ifFalse: [ ^ false ].
	gatewayDirection = 'Converging' ifTrue: [ ^ self outgoing size <= 1 ].
	gatewayDirection = 'Diverging' ifTrue: [ ^ self incoming size <= 1 ].
	gatewayDirection = 'Mixed' ifTrue: [ ^ self incoming size > 1 and: [ self outgoing size > 1 ] ].
	^ true
]
{ #category : 'descriptions' }
CPGateway >> gatewayDirectionDescription [
	<magritteDescription>
	^ MASingleOptionDescription new accessor: #gatewayDirection; label: 'Direction'; options: { 'Unspecified'. 'Converging'. 'Diverging'. 'Mixed' }; priority: 90; group: 'Gateway'; yourself
]
