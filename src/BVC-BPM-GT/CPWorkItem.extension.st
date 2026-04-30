Extension { #name : 'CPWorkItem' }

{ #category : '*bvc-bpm-gt' }
CPWorkItem >> operationsTool [
	<cfInspectorTool>
	^ CFOperationsTool forSubject: self
]

