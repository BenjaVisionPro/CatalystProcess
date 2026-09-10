"I configure Atelier editing intentions for a Process editing session.

The session supplies the semantic Process memento and the chosen staged BPMN depiction explicitly. Configuration no longer discovers or retains the Process diagram relation."
Class {
	#name : 'CPProcessAtelierConfiguration',
	#superclass : 'CFAtelierConfiguration',
	#instVars : [
		'session',
		'contextualAppendPaletteItems',
		'poolPaletteItem'
	],
	#category : 'BVC-BPM-Atelier-Configuration',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Configuration'
}

{ #category : 'instance creation' }
CPProcessAtelierConfiguration class >> forProcessMemento: aProcessMemento [
	^ self forSession: (CPProcessAtelierSession forProcessMemento: aProcessMemento)
]

{ #category : 'instance creation' }
CPProcessAtelierConfiguration class >> forSession: aSession [
	| configuration |
	configuration := self new
		session: aSession;
		yourself.
	configuration configureProcessPalette.
	^ configuration
]

{ #category : 'private - configuration' }
CPProcessAtelierConfiguration >> configureProcessPalette [
	| processPalette taskItem gatewayItem |
	processPalette := CFAtelierPalette new.
	processPalette
		add: (poolPaletteItem := CFAtelierPaletteItem
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
		icon: CPUserTask icon
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
		icon: CPExclusiveGateway icon
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
			poolPaletteItem: poolPaletteItem;
			diagramEditing: (CPProcessAtelierDiagramEditing
				processMemento: session processMemento
				diagramContext: session diagramContext);
			contextualAppendPaletteItems: contextualAppendPaletteItems ].
	^ anAtelierViewModel
]

{ #category : 'accessing' }
CPProcessAtelierConfiguration >> session [
	^ session
]

{ #category : 'accessing' }
CPProcessAtelierConfiguration >> session: aSession [
	session := aSession
]
