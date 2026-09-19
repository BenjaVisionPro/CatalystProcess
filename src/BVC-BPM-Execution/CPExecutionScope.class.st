Class {
	#name : 'CPExecutionScope',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'definition',
		'parentScope',
		'owningActivity',
		'childScopes',
		'activityExecutions',
		'acceptedOccurrences'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'instance creation' }
CPExecutionScope class >> for: aScopeDefinition ownedBy: anActivityExecution [
	^ anActivityExecution attachSubScope: (self new
		definition: aScopeDefinition;
		yourself)
]

{ #category : 'initialization' }
CPExecutionScope >> initialize [
	super initialize.
	childScopes := OrderedCollection new.
	activityExecutions := OrderedCollection new.
	acceptedOccurrences := OrderedCollection new
]

{ #category : 'accessing' }
CPExecutionScope >> definition [ ^ definition ]
{ #category : 'accessing' }
CPExecutionScope >> definition: anObject [ definition := anObject ]
{ #category : 'accessing' }
CPExecutionScope >> parentScope [ ^ parentScope ]
{ #category : 'accessing' }
CPExecutionScope >> parentScope: anExecutionScope [ parentScope := anExecutionScope ]
{ #category : 'accessing' }
CPExecutionScope >> owningActivity [ ^ owningActivity ]
{ #category : 'accessing' }
CPExecutionScope >> owningActivity: anActivityExecution [ owningActivity := anActivityExecution ]
{ #category : 'accessing' }
CPExecutionScope >> childScopes [ ^ childScopes ]
{ #category : 'accessing' }
CPExecutionScope >> activityExecutions [ ^ activityExecutions ]
{ #category : 'accessing' }
CPExecutionScope >> acceptedOccurrences [ ^ acceptedOccurrences ]

{ #category : 'building' }
CPExecutionScope >> createActivityExecutionFor: anActivity [
	^ CPActivityExecution for: anActivity in: self
]

{ #category : 'building' }
CPExecutionScope >> addActivityExecution: anActivityExecution [
	anActivityExecution scope ifNotNil: [ self error: 'The Activity execution already belongs to an execution scope.' ].
	anActivityExecution scope: self.
	activityExecutions add: anActivityExecution.
	^ anActivityExecution
]

{ #category : 'building' }
CPExecutionScope >> addChildScope: aScope [
	aScope parentScope ifNotNil: [ self error: 'The execution scope already has a parent scope.' ].
	aScope owningActivity ifNil: [ self error: 'A child execution scope must be owned by an Activity execution.' ].
	aScope owningActivity scope == self ifFalse: [ self error: 'A child execution scope must be owned by an Activity execution in its parent scope.' ].
	aScope parentScope: self.
	childScopes add: aScope.
	^ aScope
]

{ #category : 'occurrences' }
CPExecutionScope >> hasAcceptedOccurrenceIdentifiedBy: anIdentifier [
	^ acceptedOccurrences anySatisfy: [ :each | each occurrenceIdentifier = anIdentifier ]
]

{ #category : 'occurrences' }
CPExecutionScope >> acceptOccurrence: anOccurrence [
	anOccurrence occurrenceIdentifier ifNil: [ self error: 'An occurrence requires an occurrence identifier.' ].
	(self hasAcceptedOccurrenceIdentifiedBy: anOccurrence occurrenceIdentifier)
		ifTrue: [ self error: 'This occurrence has already been accepted in the scope.' ].
	acceptedOccurrences add: anOccurrence.
	^ anOccurrence
]
