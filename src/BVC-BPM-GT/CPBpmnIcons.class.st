"I provide the compact BPMN pictograms used as canonical Process object icons.

I implement the icon-library protocol consumed by FontAwesomeIconDescription while keeping the BPMN vector data owned by Catalyst Process. The returned elements are ordinary FontAwesomeIcon SVG-path elements, so Foundation sizing, colouring, Magritte visitors and icon tiles continue unchanged."
Class {
	#name : 'CPBpmnIcons',
	#superclass : 'Object',
	#category : 'BVC-BPM-GT-Icons',
	#package : 'BVC-BPM-GT',
	#tag : 'Icons'
}

{ #category : 'accessing' }
CPBpmnIcons class >> availableIconsForStyleNamed: aStyleName [
	^ {
		#startEvent -> (self icon: #startEvent styleName: aStyleName).
		#endEvent -> (self icon: #endEvent styleName: aStyleName).
		#userTask -> (self icon: #userTask styleName: aStyleName).
		#serviceTask -> (self icon: #serviceTask styleName: aStyleName).
		#sequenceFlow -> (self icon: #sequenceFlow styleName: aStyleName)
	}
]

{ #category : 'instance creation' }
CPBpmnIcons class >> icon: aSelectorSymbol [
	^ self icon: aSelectorSymbol styleName: nil
]

{ #category : 'instance creation' }
CPBpmnIcons class >> icon: aSelectorSymbol styleName: aStyleName [
	aSelectorSymbol = #startEvent ifTrue: [ ^ self startEvent ].
	aSelectorSymbol = #endEvent ifTrue: [ ^ self endEvent ].
	aSelectorSymbol = #userTask ifTrue: [ ^ self userTask ].
	aSelectorSymbol = #serviceTask ifTrue: [ ^ self serviceTask ].
	aSelectorSymbol = #sequenceFlow ifTrue: [ ^ self sequenceFlow ].
	self error: 'Unknown Catalyst Process icon: ', aSelectorSymbol asString
]

{ #category : 'private - building' }
CPBpmnIcons class >> iconNamed: aSelector label: aLabel pathSpecs: pathSpecs [
	^ FontAwesomeIcon new
		initializeName: aSelector
		styleKey: #process
		unicode: ''
		label: aLabel
		viewBox: (0 @ 0 extent: 512 @ 512)
		pathSpecs: pathSpecs
]

{ #category : 'icons' }
CPBpmnIcons class >> startEvent [
	^ self
		iconNamed: #startEvent
		label: 'Start event'
		pathSpecs: {
			Dictionary new
				at: #path put: 'M256 32C132.3 32 32 132.3 32 256s100.3 224 224 224 224-100.3 224-224S379.7 32 256 32zm0 40c101.6 0 184 82.4 184 184s-82.4 184-184 184S72 357.6 72 256 154.4 72 256 72z';
				yourself }
]

{ #category : 'icons' }
CPBpmnIcons class >> endEvent [
	^ self
		iconNamed: #endEvent
		label: 'End event'
		pathSpecs: {
			Dictionary new
				at: #path put: 'M256 24C127.9 24 24 127.9 24 256s103.9 232 232 232 232-103.9 232-232S384.1 24 256 24zm0 64c92.8 0 168 75.2 168 168s-75.2 168-168 168S88 348.8 88 256 163.2 88 256 88z';
				yourself }
]

{ #category : 'icons' }
CPBpmnIcons class >> userTask [
	^ self
		iconNamed: #userTask
		label: 'User task'
		pathSpecs: {
			Dictionary new
				at: #path put: 'M72 56h368c39.8 0 72 32.2 72 72v256c0 39.8-32.2 72-72 72H72c-39.8 0-72-32.2-72-72V128c0-39.8 32.2-72 72-72zm0 32c-22.1 0-40 17.9-40 40v256c0 22.1 17.9 40 40 40h368c22.1 0 40-17.9 40-40V128c0-22.1-17.9-40-40-40H72z';
				yourself.
			Dictionary new
				at: #path put: 'M176 174c0-44.2 35.8-80 80-80s80 35.8 80 80-35.8 80-80 80-80-35.8-80-80zm-48 210c0-70.7 57.3-128 128-128s128 57.3 128 128h-40c0-48.6-39.4-88-88-88s-88 39.4-88 88h-40z';
				yourself }
]


{ #category : 'icons' }
CPBpmnIcons class >> serviceTask [
	^ self
		iconNamed: #serviceTask
		label: 'Service task'
		pathSpecs: {
			Dictionary new
				at: #path put: 'M72 56h368c39.8 0 72 32.2 72 72v256c0 39.8-32.2 72-72 72H72c-39.8 0-72-32.2-72-72V128c0-39.8 32.2-72 72-72zm0 32c-22.1 0-40 17.9-40 40v256c0 22.1 17.9 40 40 40h368c22.1 0 40-17.9 40-40V128c0-22.1-17.9-40-40-40H72z';
				yourself.
			Dictionary new
				at: #path put: 'M256 137l18 28 33-5 5 33 28 18-18 28 18 28-28 18-5 33-33-5-18 28-18-28-33 5-5-33-28-18 18-28-18-28 28-18 5-33 33 5 18-28zm0 58c-24.3 0-44 19.7-44 44s19.7 44 44 44 44-19.7 44-44-19.7-44-44-44zm0 24c11 0 20 9 20 20s-9 20-20 20-20-9-20-20 9-20 20-20z';
				yourself }
]


{ #category : 'icons' }
CPBpmnIcons class >> sequenceFlow [
	^ self
		iconNamed: #sequenceFlow
		label: 'Sequence flow'
		pathSpecs: {
			Dictionary new
				at: #path put: 'M40 240h336v-72l112 88-112 88v-72H40z';
				yourself }
]
