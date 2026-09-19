Class { #name : 'CPEscalation', #superclass : 'CFLabelledObject', #instVars : [ 'escalationCode', 'structureRef' ], #category : 'BVC-BPM-BPMN', #package : 'BVC-BPM-BPMN' }
{ #category : 'accessing' }
CPEscalation >> escalationCode [ ^ escalationCode ]
{ #category : 'accessing' }
CPEscalation >> escalationCode: aString [ escalationCode := aString ]
{ #category : 'accessing' }
CPEscalation >> structureRef [ ^ structureRef ]
{ #category : 'accessing' }
CPEscalation >> structureRef: anItemDefinition [ structureRef := anItemDefinition ]
{ #category : 'descriptions' }
CPEscalation >> escalationCodeDescription [ <magritteDescription> ^ MAStringDescription new accessor: #escalationCode; label: 'Escalation code'; priority: 100; group: 'Escalation'; yourself ]
{ #category : 'descriptions' }
CPEscalation >> structureRefDescription [ <magritteDescription> ^ MAToOneRelationDescription new accessor: #structureRef; classes: { CPItemDefinition }; reference: CPItemDefinition new identifierDescription; label: 'Structure'; priority: 110; group: 'Data'; yourself ]
{ #category : 'accessing - presentation' }
CPEscalation class >> defaultIcon [ ^ #chevronsUp ]
