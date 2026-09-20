Class {
    #name : 'CPResourceRoleAssignment',
    #superclass : 'CFIdentifiableObject',
    #instVars : [ 'role', 'resources' ],
    #category : 'BVC-BPM-Execution',
    #package : 'BVC-BPM-Execution'
}

{ #category : 'initialization' }
CPResourceRoleAssignment >> initialize [
    super initialize.
    resources := OrderedCollection new
]

{ #category : 'accessing' }
CPResourceRoleAssignment >> role [ ^ role ]

{ #category : 'accessing' }
CPResourceRoleAssignment >> role: aResourceRole [
    role ifNotNil: [ self error: 'A resource-role assignment can reference only one BPMN ResourceRole.' ].
    aResourceRole ifNil: [ self error: 'A resource-role assignment requires a BPMN ResourceRole.' ].
    role := aResourceRole
]

{ #category : 'accessing' }
CPResourceRoleAssignment >> resources [ ^ resources ]

{ #category : 'accessing' }
CPResourceRoleAssignment >> resources: aCollection [
    resources := aCollection asOrderedCollection
]

{ #category : 'testing' }
CPResourceRoleAssignment >> isPotentialOwnerAssignment [
    ^ role isPotentialOwner
]
