Extension { #name : 'CPIntermediateEvent' }
{ #category : '*BVC-BPM-GT' }
CPIntermediateEvent >> iconDescription [
	<magritteDescription>
	^ FontAwesomeIconDescription new
		accessor: #icon;
		label: 'Icon';
		default: self class eventTypeIcon;
		iconLibraryClass: FontAwesomeIcons;
		priority: 5;
		iconHeight: 32;
		beReadOnly;
		cfSerializable: true;
		yourself
]
