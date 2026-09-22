"I carry the application information required by the Establish Tenant Administrator operation. BPMN creates me from the established tenant and the originating registration so the external operation still receives one explicit input value."
Class {
	#name : 'CPTenantAdministratorEstablishment',
	#superclass : 'Object',
	#instVars : [ 'tenant', 'registration' ],
	#category : 'BVC-BPM-Marketplace',
	#package : 'BVC-BPM-Marketplace',
	#tag : 'Marketplace'
}

{ #category : 'accessing' }
CPTenantAdministratorEstablishment >> tenant [ ^ tenant ]

{ #category : 'accessing' }
CPTenantAdministratorEstablishment >> tenant: anObject [ tenant := anObject ]

{ #category : 'accessing' }
CPTenantAdministratorEstablishment >> registration [ ^ registration ]

{ #category : 'accessing' }
CPTenantAdministratorEstablishment >> registration: anObject [ registration := anObject ]
