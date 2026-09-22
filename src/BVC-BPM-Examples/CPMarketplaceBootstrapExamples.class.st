Class {
	#name : 'CPMarketplaceBootstrapExamples',
	#superclass : 'Object',
	#category : 'BVC-BPM-Examples-Marketplace',
	#package : 'BVC-BPM-Examples',
	#tag : 'Marketplace'
}

{ #category : 'examples - marketplace bootstrap' }
CPMarketplaceBootstrapExamples >> adminBootstrapEstablishesPersistentApplicationWorld [
	<gtExample>
	| bootstrap root tenant user membership deployment |
	bootstrap := CPAdminTenantBootstrap configured.
	root := bootstrap systemRoot.
	tenant := bootstrap adminTenant.
	user := bootstrap adminUser.
	membership := bootstrap adminMembership.
	deployment := bootstrap tenantLifecycleDeployment.
	self assert: root tenants asArray equals: { tenant }.
	self assert: root users asArray equals: { user }.
	self assert: membership tenant == tenant.
	self assert: membership user == user.
	self assert: tenant memberships asArray equals: { membership }.
	self assert: user memberships asArray equals: { membership }.
	self assert: root processDeployments asArray equals: { deployment }.
	self assert: tenant processDeployments asArray equals: { deployment }.
	self assert: deployment tenant == tenant.
	self assert: deployment deployedBy == user.
	self assert: deployment processDefinition identifier equals: #provisionTenant.
	self assert: deployment isActive.
	self assert: (deployment canBeStartedBy: user).
	^ bootstrap
]

{ #category : 'examples - marketplace bootstrap' }
CPMarketplaceBootstrapExamples >> adminBootstrapConfiguresRuntimeBpmServiceOverSameSystemRoot [
	<gtExample>
	| bootstrap bpm runtime service |
	bootstrap := CPAdminTenantBootstrap configured.
	bpm := bootstrap bpmServiceConfiguration.
	runtime := bootstrap runtimeConfiguration.
	self assert: bpm identifier equals: #bpm.
	self assert: bpm serviceClass == CPBpmService.
	self assert: bpm systemRoot == bootstrap systemRoot.
	self assert: runtime services asArray equals: { bpm }.
	self assert: runtime deployment serviceDeployments size equals: 1.
	self assert: runtime deployment serviceDeployments first serviceIdentifier equals: #bpm.
	self assert: runtime validate isValid.
	service := CPBpmService new installWithConfiguration: bpm.
	self assert: (service startableProcessDeploymentsFor: bootstrap adminUser) asArray
		equals: { bootstrap tenantLifecycleDeployment }.
	^ runtime
]

{ #category : 'examples - marketplace bootstrap' }
CPMarketplaceBootstrapExamples >> adminTenantLifecycleIsProductionMarketplaceSource [
	<gtExample>
	| bootstrap definitions |
	bootstrap := CPAdminTenantBootstrap configured.
	definitions := bootstrap tenantLifecycleDefinitions.
	self assert: definitions rootElements size equals: 9.
	self assert: definitions diagrams size equals: 6.
	self assert: bootstrap tenantLifecycleDeployment processDefinition identifier equals: #provisionTenant.
	^ definitions
]
