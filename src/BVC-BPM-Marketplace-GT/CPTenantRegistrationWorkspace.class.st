"I am the GT presentation boundary for the public Tenant Registration journey. I do not require an authenticated Process user; the Marketplace application owns that use case and its Runtime commands."
Class {
	#name : 'CPTenantRegistrationWorkspace',
	#superclass : 'Object',
	#instVars : [ 'application' ],
	#category : 'BVC-BPM-Marketplace-GT',
	#package : 'BVC-BPM-Marketplace-GT'
}

{ #category : 'instance creation' }
CPTenantRegistrationWorkspace class >> application: aCPTenantRegistrationApplication [
	^ self new application: aCPTenantRegistrationApplication; yourself
]

{ #category : 'accessing' }
CPTenantRegistrationWorkspace >> application [ ^ application ]

{ #category : 'accessing' }
CPTenantRegistrationWorkspace >> application: anApplication [ application := anApplication ]

{ #category : 'private' }
CPTenantRegistrationWorkspace >> requiredApplication [
	application ifNil: [ self error: 'A Tenant Registration application is required.' ].
	^ application
]

{ #category : 'registration' }
CPTenantRegistrationWorkspace >> beginTenantRegistration [
	^ self requiredApplication beginTenantRegistration
]

{ #category : 'registration' }
CPTenantRegistrationWorkspace >> interactionFor: aCPTenantRegistration [
	| workItem |
	workItem := self requiredApplication workItemForTenantRegistration: aCPTenantRegistration.
	workItem ifNil: [ self error: 'No pending Tenant registration work item exists for the registration.' ].
	^ CPTenantRegistrationInteraction
		application: self requiredApplication
		registration: aCPTenantRegistration
		workItem: workItem
]
