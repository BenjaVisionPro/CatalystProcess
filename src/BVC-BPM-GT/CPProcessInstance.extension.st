Extension { #name : 'CPProcessInstance' }

{ #category : '*bvc-bpm-gt' }
CPProcessInstance >> gtWorkItemsFor: aView [
	<gtView>
	^ aView list
		title: 'Work items';
		priority: 20;
		items: [ self workItems ]
]

{ #category : '*bvc-bpm-gt' }
CPProcessInstance >> gtAuditFor: aView [
	<gtView>
	^ aView list
		title: 'Audit';
		priority: 30;
		items: [ self auditEvents ]
]

