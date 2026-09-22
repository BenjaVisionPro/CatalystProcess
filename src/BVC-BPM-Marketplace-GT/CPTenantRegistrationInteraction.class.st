"I present one pending public Tenant Registration interaction through Foundation. I deliberately use CPTenantRegistrationApplication rather than CPBpmApplication because a prospective registrant is not yet a CPUser."
Class {
	#name : 'CPTenantRegistrationInteraction',
	#superclass : 'Object',
	#instVars : [
		'application',
		'registration',
		'workItem',
		'memento',
		'viewModel'
	],
	#category : 'BVC-BPM-Marketplace-GT',
	#package : 'BVC-BPM-Marketplace-GT'
}

{ #category : 'instance creation' }
CPTenantRegistrationInteraction class >> application: aCPTenantRegistrationApplication registration: aCPTenantRegistration workItem: aCPUserTaskWorkItem [
	| memento |
	memento := CFMaMemento model: aCPTenantRegistration.
	^ self new
		application: aCPTenantRegistrationApplication;
		registration: aCPTenantRegistration;
		workItem: aCPUserTaskWorkItem;
		memento: memento;
		viewModel: (CFMaViewModel forObject: aCPTenantRegistration memento: memento);
		yourself
]

{ #category : 'accessing' }
CPTenantRegistrationInteraction >> application [ ^ application ]

{ #category : 'accessing' }
CPTenantRegistrationInteraction >> application: anApplication [ application := anApplication ]

{ #category : 'accessing' }
CPTenantRegistrationInteraction >> registration [ ^ registration ]

{ #category : 'accessing' }
CPTenantRegistrationInteraction >> registration: aRegistration [ registration := aRegistration ]

{ #category : 'accessing' }
CPTenantRegistrationInteraction >> workItem [ ^ workItem ]

{ #category : 'accessing' }
CPTenantRegistrationInteraction >> workItem: aWorkItem [ workItem := aWorkItem ]

{ #category : 'accessing' }
CPTenantRegistrationInteraction >> memento [ ^ memento ]

{ #category : 'accessing' }
CPTenantRegistrationInteraction >> memento: aMemento [ memento := aMemento ]

{ #category : 'accessing' }
CPTenantRegistrationInteraction >> viewModel [ ^ viewModel ]

{ #category : 'accessing' }
CPTenantRegistrationInteraction >> viewModel: aViewModel [ viewModel := aViewModel ]

{ #category : 'presentation' }
CPTenantRegistrationInteraction >> element [
	^ viewModel preparedElementForMemento: memento
]

{ #category : 'commands' }
CPTenantRegistrationInteraction >> submit [
	memento commit.
	application completeTenantRegistration: registration.
	^ registration
]
