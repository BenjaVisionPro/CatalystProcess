Extension { #name : 'CPSystemRoot' }

{ #category : '*bvc-bpm-gt' }
CPSystemRoot >> gtProcessesFor: aView [
	<gtView>
	^ aView list
		title: 'Processes';
		priority: 20;
		items: [ self processDeployments ]
]

{ #category : '*bvc-bpm-gt' }
CPSystemRoot >> gtTenantsFor: aView [
	<gtView>
	^ aView list
		title: 'Tenants';
		priority: 30;
		items: [ self tenants ]
]

