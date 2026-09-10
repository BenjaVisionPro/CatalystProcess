"I identify the semantic focus and active BPMN depiction for one Process Atelier editing session.

The transaction root is explicit even while the current legacy entry still roots the transaction at the Process itself. This keeps the session contract ready for a CPDefinitions-rooted transaction without making configuration or editing adapters rediscover diagram ownership."
Class {
	#name : 'CPProcessAtelierSession',
	#superclass : 'Object',
	#instVars : [
		'rootMemento',
		'processMemento',
		'diagramContext'
	],
	#category : 'BVC-BPM-Atelier-Configuration',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Configuration'
}

{ #category : 'instance creation' }
CPProcessAtelierSession class >> forProcessMemento: aProcessMemento [
	| diagramDescription diagram diagramContext |
	diagramDescription := aProcessMemento model diagramDescription.
	diagram := aProcessMemento readUsing: diagramDescription.
	diagramContext := diagram ifNil: [ nil ] ifNotNil: [
		CPDiagramMementoContext
			diagram: diagram
			inMemento: aProcessMemento
			using: diagramDescription ].
	^ self
		rootMemento: aProcessMemento
		processMemento: aProcessMemento
		diagramContext: diagramContext
]

{ #category : 'instance creation' }
CPProcessAtelierSession class >> rootMemento: aRootMemento processMemento: aProcessMemento diagramContext: aDiagramContext [
	^ self new
		rootMemento: aRootMemento;
		processMemento: aProcessMemento;
		diagramContext: aDiagramContext;
		yourself
]

{ #category : 'accessing' }
CPProcessAtelierSession >> rootMemento [
	^ rootMemento
]

{ #category : 'accessing' }
CPProcessAtelierSession >> rootMemento: aMemento [
	rootMemento := aMemento
]

{ #category : 'accessing' }
CPProcessAtelierSession >> processMemento [
	^ processMemento
]

{ #category : 'accessing' }
CPProcessAtelierSession >> processMemento: aMemento [
	processMemento := aMemento
]

{ #category : 'accessing' }
CPProcessAtelierSession >> diagramContext [
	^ diagramContext
]

{ #category : 'accessing' }
CPProcessAtelierSession >> diagramContext: aDiagramContext [
	diagramContext := aDiagramContext
]
