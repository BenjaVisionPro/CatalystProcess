"I prove that the Admin GT workspace presents the authoritative bootstrap installation and delegates BPM policy to CPBpmApplication."
Class {
	#name : 'CPAdminProcessWorkspaceExamples',
	#superclass : 'Object',
	#category : 'BVC-BPM-GT-Examples-Workspace',
	#package : 'BVC-BPM-GT-Examples',
	#tag : 'Workspace'
}

{ #category : 'examples - workspace' }
CPAdminProcessWorkspaceExamples >> bootstrappedAdminWorkspace [
	<gtExample>
	| bootstrap service application workspace |
	bootstrap := CPAdminTenantBootstrap configured.
	service := CPBpmService new installWithConfiguration: bootstrap bpmServiceConfiguration.
	application := CPBpmApplication
		runtime: nil
		bpmService: service
		user: bootstrap adminUser.
	workspace := CPAdminProcessWorkspace
		bootstrap: bootstrap
		application: application.

	self assert: workspace systemRoot == bootstrap systemRoot.
	self assert: workspace marketplace == bootstrap marketplace.
	self assert: workspace adminTenant == bootstrap adminTenant.
	self assert: workspace administrator == bootstrap adminUser.
	self assert: workspace runtimeConfiguration == bootstrap runtimeConfiguration.
	self assert: workspace startableProcessDeployments size equals: 1.
	self assert: workspace startableProcessDeployments first == bootstrap tenantLifecycleDeployment.
	self assert: workspace assignedUserTaskWorkItems isEmpty.
	self assert: workspace claimableUserTaskWorkItems isEmpty.
	^ workspace
]
