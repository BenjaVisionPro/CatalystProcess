"I prove that the GT BPM workspace is a thin presentation over the authenticated application boundary."
Class {
	#name : 'CPBpmWorkspaceExamples',
	#superclass : 'Object',
	#category : 'BVC-BPM-GT-Examples-Workspace',
	#package : 'BVC-BPM-GT-Examples',
	#tag : 'Workspace'
}

{ #category : 'examples - workspace' }
CPBpmWorkspaceExamples >> workspaceUsesAuthenticatedApplicationBoundary [
	<gtExample>
	| root user service application workspace |
	root := CPSystemRoot new.
	user := CPUser new.
	root addUser: user.
	service := CPBpmService new installWithConfiguration:
		(CPBpmServiceConfiguration new systemRoot: root; yourself).
	application := CPBpmApplication
		runtime: nil
		bpmService: service
		user: user.
	workspace := CPBpmWorkspace application: application.

	self assert: workspace application == application.
	self assert: application user == user.
	self assert: application startableProcessDeployments isEmpty.
	self assert: application assignedUserTaskWorkItems isEmpty.
	self assert: application claimableUserTaskWorkItems isEmpty.
	^ workspace
]
