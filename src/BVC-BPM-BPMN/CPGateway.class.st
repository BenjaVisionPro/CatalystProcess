Class {
	#name : 'CPGateway',
	#superclass : 'CPFlowNode',
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
