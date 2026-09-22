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


{ #category : 'examples - workspace' }
CPBpmWorkspaceExamples >> workspaceCompletesUserTaskThroughRuntimeCommand [
	<gtExample>
	| root user service runtime topology host queue worker serviceHandle application workspace workItem envelope |
	root := CPSystemRoot new.
	user := CPUser new.
	root addUser: user.
	service := CPBpmService new installWithConfiguration:
		(CPBpmServiceConfiguration new systemRoot: root; yourself).
	runtime := CRRuntime new.
	topology := CRDeploymentTopology new.
	host := topology ensureHostNamed: #localhost.
	queue := CRPharoWorkQueue new.
	worker := CRWorkerHandle new
		workerIdentifier: #bpmWorkspaceWorker;
		workQueue: queue;
		lifecycleStatus: CRStatus running;
		yourself.
	serviceHandle := worker
		ensureServiceHandleForIdentifier: #bpm
		serviceClass: CPBpmService.
	serviceHandle lifecycleStatus: CRStatus running.
	host noteWorkerHandle: worker.
	runtime deploymentTopology: topology.
	application := CPBpmApplication
		runtime: runtime
		bpmService: service
		user: user.
	workspace := CPBpmWorkspace application: application.
	workItem := CPUserTaskWorkItem new.

	self assert: (workspace completeUserTaskWorkItem: workItem) == workItem.
	self assert: queue depth equals: 1.
	envelope := queue nextOrNil.
	self assert: envelope workUnit class equals: CPCompleteUserTaskWorkUnit.
	self assert: envelope workUnit workItem == workItem.
	^ workspace
]
