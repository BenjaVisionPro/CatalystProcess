Class {
	#name : 'CPScriptTask',
	#superclass : 'CPTask',
	#instVars : [ 'scriptFormat', 'script' ],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'task type' }
CPScriptTask class >> taskTypeLabel [
	^ 'Script'
]

{ #category : 'task type' }
CPScriptTask class >> taskTypeIcon [
	^ #scroll
]

{ #category : 'defaults' }
CPScriptTask class >> defaultIcon [
	^ self taskTypeIcon
]

{ #category : 'accessing' }
CPScriptTask >> scriptFormat [
	^ scriptFormat
]

{ #category : 'accessing' }
CPScriptTask >> scriptFormat: aString [
	scriptFormat := aString
]

{ #category : 'accessing' }
CPScriptTask >> script [
	^ script
]

{ #category : 'accessing' }
CPScriptTask >> script: aString [
	script := aString
]

{ #category : 'descriptions' }
CPScriptTask >> scriptFormatDescription [
	<magritteDescription>
	^ MAStringDescription new
		accessor: #scriptFormat;
		label: 'Script format';
		priority: 100;
		group: 'Execution';
		yourself
]

{ #category : 'descriptions' }
CPScriptTask >> scriptDescription [
	<magritteDescription>
	^ MAStringDescription new
		accessor: #script;
		label: 'Script';
		priority: 110;
		group: 'Execution';
		yourself
]
