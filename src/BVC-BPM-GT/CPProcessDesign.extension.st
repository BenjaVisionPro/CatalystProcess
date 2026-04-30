Extension { #name : 'CPProcessDesign' }

{ #category : '*bvc-bpm-gt' }
CPProcessDesign >> operationsTool [
	<cfInspectorTool>
	^ CFOperationsTool forSubject: self
]

