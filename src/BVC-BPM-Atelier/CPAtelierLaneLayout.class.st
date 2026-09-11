"I define Atelier's geometric layout rules for BPMN Lanes.

These are editing and auto-layout rules, not renderer rules. BPMN DI remains authoritative for projection."
Class {
	#name : 'CPAtelierLaneLayout',
	#superclass : 'Object',
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'geometry' }
CPAtelierLaneLayout class >> minimumLaneHeight [
	^ 140
]

{ #category : 'geometry' }
CPAtelierLaneLayout class >> contentClearance [
	"Minimum clear space retained above and below the vertical envelope of FlowNodes when a horizontal Lane is compressed by Atelier layout."
	^ 20
]
