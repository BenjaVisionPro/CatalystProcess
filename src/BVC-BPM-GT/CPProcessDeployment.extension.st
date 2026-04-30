Extension { #name : 'CPProcessDeployment' }

{ #category : '*bvc-bpm-gt' }
CPProcessDeployment >> operationsTool [
	<cfInspectorTool>
	^ CFOperationsTool forSubject: self
]

