Class {
	#name : 'CPArtifact',
	#superclass : 'CFLabelledObject',
	#instVars : [ 'container' ],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'accessing' }
CPArtifact >> container [ ^ container ]

{ #category : 'accessing' }
CPArtifact >> container: aFlowElementsContainer [ container := aFlowElementsContainer ]
