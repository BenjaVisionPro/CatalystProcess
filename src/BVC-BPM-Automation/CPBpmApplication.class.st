"I am the co-resident application boundary for authenticated BPM users. I expose authoritative Process reads directly and route state-changing commands through Catalyst Runtime. Presentation clients collaborate with me rather than reproducing CPBpmService policy or mutating Process execution objects directly."
Class {
	#name : 'CPBpmApplication',
	#superclass : 'Object',
	#instVars : [
		'runtime',
		'bpmService',
		'user'
	],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'instance creation' }
CPBpmApplication class >> runtime: aCRRuntime bpmService: aCPBpmService user: aCPUser [
	^ self new
		runtime: aCRRuntime;
		bpmService: aCPBpmService;
		user: aCPUser;
		yourself
]

{ #category : 'queries' }
CPBpmApplication >> startableProcessDeployments [
	^ self requiredBpmService startableProcessDeploymentsFor: self requiredUser
]

{ #category : 'queries' }
CPBpmApplication >> assignedUserTaskWorkItems [
	^ self requiredBpmService assignedUserTaskWorkItemsFor: self requiredUser
]

{ #category : 'queries' }
CPBpmApplication >> claimableUserTaskWorkItems [
	^ self requiredBpmService claimableUserTaskWorkItemsFor: self requiredUser
]

{ #category : 'commands' }
CPBpmApplication >> startProcessDeployment: aCPProcessDeployment [
	aCPProcessDeployment ifNil: [ self error: 'A Process deployment is required.' ].
	self enqueue: (CPStartProcessWorkUnit
		processDeployment: aCPProcessDeployment
		user: self requiredUser).
	^ aCPProcessDeployment
]

{ #category : 'commands' }
CPBpmApplication >> claimUserTaskWorkItem: aCPUserTaskWorkItem [
	aCPUserTaskWorkItem ifNil: [ self error: 'A User Task work item is required.' ].
	self enqueue: (CPClaimUserTaskWorkItemWorkUnit
		workItem: aCPUserTaskWorkItem
		user: self requiredUser).
	^ aCPUserTaskWorkItem
]


{ #category : 'commands' }
CPBpmApplication >> completeUserTaskWorkItem: aCPUserTaskWorkItem [
	aCPUserTaskWorkItem ifNil: [ self error: 'A User Task work item is required.' ].
	self enqueue: (CPCompleteUserTaskWorkUnit workItem: aCPUserTaskWorkItem).
	^ aCPUserTaskWorkItem
]

{ #category : 'private' }
CPBpmApplication >> enqueue: aWorkUnit [
	| router |
	runtime ifNil: [ self error: 'Catalyst Runtime is required for BPM commands.' ].
	router := CRWorkRouter deploymentTopology: runtime deploymentTopology.
	router enqueue: aWorkUnit
]

{ #category : 'private' }
CPBpmApplication >> requiredBpmService [
	bpmService ifNil: [ self error: 'BPM service is required.' ].
	^ bpmService
]

{ #category : 'private' }
CPBpmApplication >> requiredUser [
	user ifNil: [ self error: 'A Process user is required.' ].
	^ user
]

{ #category : 'accessing' }
CPBpmApplication >> runtime [ ^ runtime ]

{ #category : 'accessing' }
CPBpmApplication >> runtime: aCRRuntime [ runtime := aCRRuntime ]

{ #category : 'accessing' }
CPBpmApplication >> bpmService [ ^ bpmService ]

{ #category : 'accessing' }
CPBpmApplication >> bpmService: aCPBpmService [ bpmService := aCPBpmService ]

{ #category : 'accessing' }
CPBpmApplication >> user [ ^ user ]

{ #category : 'accessing' }
CPBpmApplication >> user: aCPUser [ user := aCPUser ]
