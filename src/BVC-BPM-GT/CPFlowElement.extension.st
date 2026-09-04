Extension { #name : 'CPFlowElement' }

{ #category : '*BVC-BPM-GT' }
CPFlowElement >> iconDescription [
	<magritteDescription>
	^ FontAwesomeIconDescription new
		accessor: #icon;
		label: 'Icon';
		default: self defaultIcon;
		iconLibraryClass: CPBpmnIcons;
		priority: 5;
		iconHeight: 32;
		beReadOnly;
		cfSerializable: true;
		yourself
]
