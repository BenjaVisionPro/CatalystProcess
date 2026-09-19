"I represent a BPMN Error that can be returned by a failed Operation or carried by an Error Event."
Class {
	#name : 'CPError',
	#superclass : 'CFLabelledObject',
	#instVars : [ 'structureRef', 'errorCode' ],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}
{ #category : 'accessing' }
CPError >> structureRef [ ^ structureRef ]
{ #category : 'accessing' }
CPError >> structureRef: anItemDefinition [ structureRef := anItemDefinition ]
{ #category : 'accessing' }
CPError >> errorCode [ ^ errorCode ]
{ #category : 'accessing' }
CPError >> errorCode: aString [ errorCode := aString ]
{ #category : 'descriptions' }
CPError >> structureRefDescription [ <magritteDescription> ^ MAToOneRelationDescription new accessor: #structureRef; classes: { CPItemDefinition }; reference: CPItemDefinition new identifierDescription; label: 'Structure'; priority: 100; group: 'Data'; yourself ]
{ #category : 'descriptions' }
CPError >> errorCodeDescription [ <magritteDescription> ^ MAStringDescription new accessor: #errorCode; label: 'Error code'; priority: 110; group: 'Error'; yourself ]
{ #category : 'accessing - presentation' }
CPError class >> defaultIcon [ ^ #circleExclamation ]
