"I configure Atelier editing intentions for the production CPProcess visual presentation.

The semantic model remains Magritte-described. I retain the exact root diagram description and translate the production visual editing gestures into Process-specific Atelier operations. Presentation selection remains owned by the CPProcess Magritte container."
Class {
	#name : 'CPProcessAtelierConfiguration',
	#superclass : 'CFAtelierConfiguration',
	#instVars : [
		'diagramDescription',
		'flowElementsDescription',
		'contextualAppendPaletteItems'
	],
	#category : 'BVC-BPM-Atelier-Configuration',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Configuration'
}

{ #category : 'instance creation' }
CPProcessAtelierConfiguration class >> forProcessMemento: aProcessMemento [
	| diagramDescription flowElementsDescription configuration |
	diagramDescription := aProcessMemento magritteDescription detect: [ :each | each handlesSelector: #diagram ].
	flowElementsDescription := aProcessMemento magritteDescription detect: [ :each | each handlesSelector: #flowElements ].
	configuration := self new
		diagramDescription: diagramDescription;
		flowElementsDescription: flowElementsDescription;
		yourself.
	configuration configureProcessPalette.
	^ configuration
]

{ #category : 'private - configuration' }
CPProcessAtelierConfiguration >> configureProcessPalette [
	| processPalette taskItem gatewayItem |
	processPalette := CFAtelierPalette new.
	processPalette
		add: (CFAtelierPaletteItem
			label: 'Pool'
			icon: CPParticipant icon
			provider: (CFAtelierFactoryProvider factory: [
				CPParticipant new label: 'Pool'; yourself ]));
		add: (CFAtelierPaletteItem
			label: 'Start event'
			icon: CPNoneStartEvent icon
			provider: (CFAtelierFactoryProvider factory: [
				CPNoneStartEvent new label: 'Start'; yourself ]));
		add: (CFAtelierPaletteItem
			label: 'End event'
			icon: CPNoneEndEvent icon
			provider: (CFAtelierFactoryProvider factory: [
				CPNoneEndEvent new label: 'End'; yourself ]));
		add: (CFAtelierPaletteItem
			label: 'Intermediate event'
			icon: CPTimerIntermediateEvent icon
			provider: (CFAtelierFactoryProvider factory: [
				CPTimerIntermediateEvent new label: 'Event'; yourself ]));
		add: (CFAtelierPaletteItem
			label: 'Boundary event'
			icon: CPBoundaryEvent icon
			provider: (CFAtelierFactoryProvider factory: [
				CPBoundaryEvent new
					label: 'Boundary';
					eventDefinitions: { CPTimerEventDefinition new } asOrderedCollection;
					yourself ])).
	taskItem := processPalette add: (CFAtelierPaletteItem
		label: 'Task'
		icon: [ (FontAwesomeIcons defaultStyle icon: #rectangle) height: 20 ] asStencil
		provider: (CFAtelierFactoryProvider factory: [
			CPUserTask new label: 'Task'; yourself ])).
	processPalette
		add: (CFAtelierPaletteItem
			label: 'Call activity'
			icon: CPCallActivity icon
			provider: (CFAtelierFactoryProvider factory: [
				CPCallActivity new label: 'Call activity'; yourself ]));
		add: (CFAtelierPaletteItem
			label: 'Sub-process'
			icon: CPSubProcess icon
			provider: (CFAtelierFactoryProvider factory: [
				CPNoneSubProcess new label: 'Sub-process'; yourself ])).
	gatewayItem := processPalette add: (CFAtelierPaletteItem
		label: 'Gateway'
		icon: [ (FontAwesomeIcons defaultStyle icon: #diamond) height: 20 ] asStencil
		provider: (CFAtelierFactoryProvider factory: [
			CPExclusiveGateway new label: 'Gateway'; yourself ])).
	self palette: processPalette.
	contextualAppendPaletteItems := { taskItem. gatewayItem }
]

{ #category : 'applying' }
CPProcessAtelierConfiguration >> applyEditingTo: anAtelierViewModel [
	super applyEditingTo: anAtelierViewModel.
	anAtelierViewModel presentationDo: [ :aPresentation |
		aPresentation
			diagramEditing: (CPProcessAtelierDiagramEditing
				processMemento: aPresentation memento
				diagramDescription: diagramDescription);
			contextualAppendPaletteItems: contextualAppendPaletteItems ].
	^ anAtelierViewModel
]

{ #category : 'accessing' }
CPProcessAtelierConfiguration >> diagramDescription [
	^ diagramDescription
]

{ #category : 'accessing' }
CPProcessAtelierConfiguration >> diagramDescription: aDescription [
	diagramDescription := aDescription
]

{ #category : 'accessing' }
CPProcessAtelierConfiguration >> flowElementsDescription [ ^ flowElementsDescription ]
{ #category : 'accessing' }
CPProcessAtelierConfiguration >> flowElementsDescription: aDescription [ flowElementsDescription := aDescription ]
