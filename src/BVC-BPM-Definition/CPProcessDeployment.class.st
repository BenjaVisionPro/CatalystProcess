Class {
	#name : 'CPProcessDeployment',
	#superclass : 'CFLabelledObject',
	#instVars : [
		'tenant',
		'sourceDesign',
		'processKey',
		'version',
		'compiledDefinition',
		'deployedAt',
		'deployedBy',
		'status'
	],
	#category : 'BVC-BPM-Definition',
	#package : 'BVC-BPM-Definition'
}

{ #category : 'accessing' }
CPProcessDeployment >> tenant [
	^ tenant
]

{ #category : 'accessing' }
CPProcessDeployment >> tenant: anObject [
	tenant := anObject
]

{ #category : 'accessing' }
CPProcessDeployment >> sourceDesign [
	^ sourceDesign
]

{ #category : 'accessing' }
CPProcessDeployment >> sourceDesign: anObject [
	sourceDesign := anObject
]

{ #category : 'accessing' }
CPProcessDeployment >> processKey [
	^ processKey
]

{ #category : 'accessing' }
CPProcessDeployment >> processKey: anObject [
	processKey := anObject
]

{ #category : 'accessing' }
CPProcessDeployment >> version [
	^ version
]

{ #category : 'accessing' }
CPProcessDeployment >> version: anObject [
	version := anObject
]

{ #category : 'accessing' }
CPProcessDeployment >> compiledDefinition [
	^ compiledDefinition
]

{ #category : 'accessing' }
CPProcessDeployment >> compiledDefinition: anObject [
	compiledDefinition := anObject
]

{ #category : 'accessing' }
CPProcessDeployment >> deployedAt [
	^ deployedAt
]

{ #category : 'accessing' }
CPProcessDeployment >> deployedAt: anObject [
	deployedAt := anObject
]

{ #category : 'accessing' }
CPProcessDeployment >> deployedBy [
	^ deployedBy
]

{ #category : 'accessing' }
CPProcessDeployment >> deployedBy: anObject [
	deployedBy := anObject
]

{ #category : 'accessing' }
CPProcessDeployment >> status [
	^ status
]

{ #category : 'accessing' }
CPProcessDeployment >> status: anObject [
	status := anObject
]

{ #category : 'initialization' }
CPProcessDeployment >> initialize [
	super initialize.
	status := #draft
]

{ #category : 'testing' }
CPProcessDeployment >> isActive [
	^ status = #active
]

{ #category : 'actions' }
CPProcessDeployment >> activate [
	status := #active
]

{ #category : 'actions' }
CPProcessDeployment >> retire [
	status := #retired
]

