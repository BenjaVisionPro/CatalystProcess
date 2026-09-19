Class {
	#name : 'CPBPMNResourceExamples',
	#superclass : 'Object',
	#category : 'BVC-BPM-Examples',
	#package : 'BVC-BPM-Examples'
}

{ #category : 'examples' }
CPBPMNResourceExamples >> potentialOwnerByResource [
	<gtExample>
	| resource parameter role binding task |
	resource := (CPResource identifier: #regionalManager) label: 'Regional manager'; yourself.
	parameter := (CPResourceParameter identifier: #region) label: 'Region'; isRequired: true; yourself.
	resource addResourceParameter: parameter.
	role := CPPotentialOwner identifier: #approver.
	role resourceRef: resource.
	binding := CPResourceParameterBinding identifier: #regionBinding.
	binding parameterRef: parameter.
	binding expression: ((CPFormalExpression identifier: #regionExpression) body: 'region'; yourself).
	role resourceParameterBindings add: binding.
	task := CPUserTask identifier: #approveOrder.
	task resources add: role.
	self assert: role hasValidAssignment.
	self assert: task resources first == role.
	^ task
]

{ #category : 'examples' }
CPBPMNResourceExamples >> assignmentMechanismsAreExclusive [
	<gtExample>
	| role |
	role := CPResourceRole identifier: #performer.
	role resourceRef: (CPResource identifier: #reviewer).
	role resourceAssignmentExpression: ((CPResourceAssignmentExpression identifier: #assignment) expression: ((CPFormalExpression identifier: #expression) body: 'reviewers'; yourself); yourself).
	self assert: role hasValidAssignment not.
	^ role
]
