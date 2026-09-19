Class {
	#name : 'CPResourceParameter',
	#superclass : 'CFLabelledObject',
	#instVars : [ 'type', 'isRequired' ],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}
{ #category : 'initialization' }
CPResourceParameter >> initialize [ super initialize. isRequired := false ]
{ #category : 'accessing' }
CPResourceParameter >> type [ ^ type ]
{ #category : 'accessing' }
CPResourceParameter >> type: anItemDefinition [ type := anItemDefinition ]
{ #category : 'accessing' }
CPResourceParameter >> isRequired [ ^ isRequired ]
{ #category : 'accessing' }
CPResourceParameter >> isRequired: aBoolean [ isRequired := aBoolean ]
{ #category : 'descriptions' }
CPResourceParameter >> typeDescription [ <magritteDescription> ^ MAToOneRelationDescription new accessor: #type; classes: { CPItemDefinition }; reference: CPItemDefinition new identifierDescription; label: 'Type'; priority: 100; group: 'Data'; yourself ]
{ #category : 'descriptions' }
CPResourceParameter >> isRequiredDescription [ <magritteDescription> ^ MABooleanDescription new accessor: #isRequired; label: 'Required'; priority: 110; group: 'Data'; yourself ]
