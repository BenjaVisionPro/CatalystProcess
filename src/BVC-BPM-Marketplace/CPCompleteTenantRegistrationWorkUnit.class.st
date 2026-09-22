"I complete the tenant-registration human interaction as Runtime work. I publish the actual registration object to the User Task output before invoking ordinary User Task completion semantics."
Class {
	#name : 'CPCompleteTenantRegistrationWorkUnit',
	#superclass : 'CRWorkUnit',
	#instVars : [
		'workItem',
		'registration'
	],
	#category : 'BVC-BPM-Marketplace',
	#package : 'BVC-BPM-Marketplace',
	#tag : 'Marketplace'
}

{ #category : 'service context' }
CPCompleteTenantRegistrationWorkUnit class >> serviceClass [
	^ CPBpmService
]

{ #category : 'instance creation' }
CPCompleteTenantRegistrationWorkUnit class >> workItem: aWorkItem registration: aTenantRegistration [
	^ self new
		workItem: aWorkItem;
		registration: aTenantRegistration;
		yourself
]

{ #category : 'accessing' }
CPCompleteTenantRegistrationWorkUnit >> registration [
	^ registration
]

{ #category : 'accessing' }
CPCompleteTenantRegistrationWorkUnit >> registration: aTenantRegistration [
	registration := aTenantRegistration
]

{ #category : 'accessing' }
CPCompleteTenantRegistrationWorkUnit >> workItem [
	^ workItem
]

{ #category : 'accessing' }
CPCompleteTenantRegistrationWorkUnit >> workItem: aWorkItem [
	workItem := aWorkItem
]

{ #category : 'running' }
CPCompleteTenantRegistrationWorkUnit >> executeInContext: aCRWorkUnitExecutionContext [
	^ aCRWorkUnitExecutionContext service completeTenantRegistrationWorkUnit: self
]
