Class { #name : 'CPSignal', #superclass : 'CFLabelledObject', #instVars : [ 'structureRef' ], #category : 'BVC-BPM-BPMN', #package : 'BVC-BPM-BPMN' }
{ #category : 'accessing' }
CPSignal >> structureRef [ ^ structureRef ]
{ #category : 'accessing' }
CPSignal >> structureRef: anItemDefinition [ structureRef := anItemDefinition ]
{ #category : 'descriptions' }
CPSignal >> structureRefDescription [ <magritteDescription> ^ MAToOneRelationDescription new accessor: #structureRef; classes: { CPItemDefinition }; reference: CPItemDefinition new identifierDescription; label: 'Structure'; priority: 100; group: 'Data'; yourself ]
{ #category : 'accessing - presentation' }
CPSignal class >> defaultIcon [ ^ #towerBroadcast ]
