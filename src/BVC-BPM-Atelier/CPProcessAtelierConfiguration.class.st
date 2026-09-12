"I configure Atelier editing intentions for a Process editing session.

The session supplies the semantic Process memento and the chosen staged BPMN depiction explicitly. Configuration no longer discovers or retains the Process diagram relation."
Class {
	#name : 'CPProcessAtelierConfiguration',
	#superclass : 'CFAtelierConfiguration',
	#instVars : [
		'session',
		'contextualAppendPaletteItems',
		'poolPaletteItem',
		'eventPaletteItem'
	],
	#category : 'BVC-BPM-Atelier-Configuration',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Configuration'
}

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
	| processPalette startItem endItem taskItem gatewayItem subProcessItem callActivityItem paletteRows |
	processPalette := CFAtelierPalette new.
	startItem := processPalette add: (CFAtelierPaletteItem
		label: 'Start event'
		icon: CPProcessPaletteIcons startEvent
		provider: (CFAtelierFactoryProvider factory: [
			CPNoneStartEvent new label: 'Start'; yourself ])).
	endItem := processPalette add: (CFAtelierPaletteItem
		label: 'End event'
		icon: CPProcessPaletteIcons endEvent
		provider: (CFAtelierFactoryProvider factory: [
			CPNoneEndEvent new label: 'End'; yourself ])).
	eventPaletteItem := processPalette add: (CFAtelierPaletteItem
		label: 'Event'
		icon: CPProcessPaletteIcons event
		provider: (CFAtelierFactoryProvider factory: [
			CPTimerIntermediateEvent new label: 'Event'; yourself ])).
	taskItem := processPalette add: (CFAtelierPaletteItem
		label: 'Activity'
		icon: CPProcessPaletteIcons activity
		provider: (CFAtelierFactoryProvider factory: [
			CPUserTask new label: 'Activity'; yourself ])).
	gatewayItem := processPalette add: (CFAtelierPaletteItem
		label: 'Gateway'
		icon: CPProcessPaletteIcons gateway
		provider: (CFAtelierFactoryProvider factory: [
			CPExclusiveGateway new label: 'Gateway'; yourself ])).
	subProcessItem := processPalette add: (CFAtelierPaletteItem
		label: 'Sub-process'
		icon: CPProcessPaletteIcons subProcess
		provider: (CFAtelierFactoryProvider factory: [
			CPNoneSubProcess new label: 'Sub-process'; yourself ])).
	callActivityItem := processPalette add: (CFAtelierPaletteItem
		label: 'Call activity'
		icon: CPProcessPaletteIcons callActivity
		provider: (CFAtelierFactoryProvider factory: [
			CPCallActivity new label: 'Call activity'; yourself ])).
	poolPaletteItem := processPalette add: (CFAtelierPaletteItem
		label: 'Pool / Lane'
		icon: CPProcessPaletteIcons poolLane
		provider: (CFAtelierFactoryProvider factory: [
			CPParticipant new label: 'Pool'; yourself ])).
	paletteRows := {
		{ startItem. endItem. eventPaletteItem }.
		{ taskItem. gatewayItem }.
		{ subProcessItem. callActivityItem }.
		{ poolPaletteItem } }.
	self
		palette: processPalette;
		paletteElementFactory: [
			CPProcessPaletteElement new
				paletteRows: paletteRows;
				yourself ].
	contextualAppendPaletteItems := { taskItem. gatewayItem }
]

{ #category : 'applying' }
CPProcessAtelierConfiguration >> applyEditingTo: anAtelierViewModel [
	super applyEditingTo: anAtelierViewModel.
	anAtelierViewModel presentationDo: [ :aPresentation |
		aPresentation
			transactionMemento: session rootMemento;
			documentContext: session documentContext;
			diagramContext: session diagramContext;
			poolPaletteItem: poolPaletteItem;
			eventPaletteItem: eventPaletteItem;
			diagramEditing: (CPProcessAtelierDiagramEditing
				processMemento: session processMemento
				diagramContext: session diagramContext
				collaborationContext: session collaborationContext
				documentContext: session documentContext);
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
