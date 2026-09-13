"I represent a BPMN Intermediate Catch Event used in normal flow."
Class {
	#name : 'CPIntermediateCatchEvent',
	#superclass : 'CPCatchEvent',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'testing' }
CPIntermediateCatchEvent >> isIntermediateEvent [ ^ true ]

{ #category : 'defaults' }
CPIntermediateCatchEvent class >> defaultIcon [ ^ #intermediateEvent ]
