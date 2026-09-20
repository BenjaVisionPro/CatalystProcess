Class {
	#name : 'CPAssociation',
	#superclass : 'CPArtifact',
	#instVars : [ 'sourceRef', 'targetRef', 'associationDirection' ],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'initialization' }
CPAssociation >> initialize [
	super initialize.
	associationDirection := 'None'
]

{ #category : 'accessing' }
CPAssociation >> sourceRef [ ^ sourceRef ]

{ #category : 'accessing' }
CPAssociation >> sourceRef: aBaseElement [ sourceRef := aBaseElement ]

{ #category : 'accessing' }
CPAssociation >> targetRef [ ^ targetRef ]

{ #category : 'accessing' }
CPAssociation >> targetRef: aBaseElement [ targetRef := aBaseElement ]

{ #category : 'accessing' }
CPAssociation >> associationDirection [ ^ associationDirection ]

{ #category : 'accessing' }
CPAssociation >> associationDirection: aString [ associationDirection := aString ]

{ #category : 'directions' }
CPAssociation >> beOne [ associationDirection := 'One' ]

{ #category : 'directions' }
CPAssociation >> beBoth [ associationDirection := 'Both' ]

{ #category : 'directions' }
CPAssociation >> beNone [ associationDirection := 'None' ]


{ #category : 'testing' }
CPAssociation >> isAssociation [ ^ true ]
