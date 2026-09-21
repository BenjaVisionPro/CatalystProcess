Class {
	#name : 'CPProcessDeploymentSnapshot',
	#superclass : 'CFObject',
	#instVars : [
		'deploymentIdentifier',
		'label',
		'tenantIdentifier',
		'processIdentifier',
		'processKey',
		'version',
		'deployedAt',
		'draft',
		'active',
		'retired',
		'acceptsNewProcessExecutions'
	],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'instance creation' }
CPProcessDeploymentSnapshot class >> from: aCPProcessDeployment [
	^ self new
		initializeFrom: aCPProcessDeployment;
		yourself
]

{ #category : 'initialization' }
CPProcessDeploymentSnapshot >> initializeFrom: aCPProcessDeployment [
	deploymentIdentifier := aCPProcessDeployment identifier.
	label := aCPProcessDeployment label.
	tenantIdentifier := aCPProcessDeployment tenant
		ifNotNil: [ :tenant | tenant identifier ].
	processIdentifier := aCPProcessDeployment processDefinition
		ifNotNil: [ :process | process identifier ].
	processKey := aCPProcessDeployment processKey.
	version := aCPProcessDeployment version.
	deployedAt := aCPProcessDeployment deployedAt.
	draft := aCPProcessDeployment isDraft.
	active := aCPProcessDeployment isActive.
	retired := aCPProcessDeployment isRetired.
	acceptsNewProcessExecutions := aCPProcessDeployment acceptsNewProcessExecutions.
	^ self
]

{ #category : 'accessing' }
CPProcessDeploymentSnapshot >> deploymentIdentifier [ ^ deploymentIdentifier ]
{ #category : 'accessing' }
CPProcessDeploymentSnapshot >> label [ ^ label ]
{ #category : 'accessing' }
CPProcessDeploymentSnapshot >> tenantIdentifier [ ^ tenantIdentifier ]
{ #category : 'accessing' }
CPProcessDeploymentSnapshot >> processIdentifier [ ^ processIdentifier ]
{ #category : 'accessing' }
CPProcessDeploymentSnapshot >> processKey [ ^ processKey ]
{ #category : 'accessing' }
CPProcessDeploymentSnapshot >> version [ ^ version ]
{ #category : 'accessing' }
CPProcessDeploymentSnapshot >> deployedAt [ ^ deployedAt ]
{ #category : 'testing' }
CPProcessDeploymentSnapshot >> isDraft [ ^ draft ]
{ #category : 'testing' }
CPProcessDeploymentSnapshot >> isActive [ ^ active ]
{ #category : 'testing' }
CPProcessDeploymentSnapshot >> isRetired [ ^ retired ]
{ #category : 'testing' }
CPProcessDeploymentSnapshot >> acceptsNewProcessExecutions [ ^ acceptsNewProcessExecutions ]
