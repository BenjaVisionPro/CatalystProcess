Class {
	#name : 'CPTenantMembership',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'tenant',
		'user',
		'groups',
		'roles'
	],
	#category : 'BVC-BPM-Core',
	#package : 'BVC-BPM-Core'
}


{ #category : 'instance creation' }
CPTenantMembership class >> tenant: aTenant user: aUser [
	| membership |
	aTenant ifNil: [ self error: 'A Tenant is required.' ].
	aUser ifNil: [ self error: 'A User is required.' ].
	(aTenant memberships anySatisfy: [ :each | each user == aUser ]) ifTrue: [
		self error: 'The User already has a membership in this Tenant.' ].
	membership := self new tenant: aTenant; user: aUser; yourself.
	aTenant memberships add: membership.
	aUser memberships add: membership.
	^ membership
]

{ #category : 'accessing' }
CPTenantMembership >> tenant [
	^ tenant
]

{ #category : 'accessing' }
CPTenantMembership >> tenant: anObject [
	tenant := anObject
]

{ #category : 'accessing' }
CPTenantMembership >> user [
	^ user
]

{ #category : 'accessing' }
CPTenantMembership >> user: anObject [
	user := anObject
]

{ #category : 'accessing' }
CPTenantMembership >> groups [
	^ groups
]

{ #category : 'accessing' }
CPTenantMembership >> groups: anObject [
	groups := anObject
]

{ #category : 'accessing' }
CPTenantMembership >> roles [
	^ roles
]

{ #category : 'accessing' }
CPTenantMembership >> roles: anObject [
	roles := anObject
]

{ #category : 'initialization' }
CPTenantMembership >> initialize [
	super initialize.
	groups := OrderedCollection new.
	roles := OrderedCollection new
]

{ #category : 'descriptions' }
CPTenantMembership >> tenantDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #tenant;
		label: 'Tenant';
		priority: 10;
		group: 'Relations';
		yourself
]

{ #category : 'descriptions' }
CPTenantMembership >> userDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #user;
		label: 'User';
		priority: 20;
		group: 'Relations';
		yourself
]

{ #category : 'descriptions' }
CPTenantMembership >> groupsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #groups;
		label: 'Groups';
		priority: 30;
		group: 'Relations';
		yourself
]

{ #category : 'descriptions' }
CPTenantMembership >> rolesDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #roles;
		label: 'Roles';
		priority: 40;
		group: 'Relations';
		yourself
]

