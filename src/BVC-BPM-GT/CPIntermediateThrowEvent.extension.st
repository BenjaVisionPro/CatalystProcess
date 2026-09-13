Extension { #name : 'CPIntermediateThrowEvent' }
{ #category : '*BVC-BPM-GT' }
CPIntermediateThrowEvent >> iconDescription [
	<magritteDescription>
	^ FontAwesomeIconDescription new
		accessor: #icon;
		label: 'Icon';
		default: self class eventTypeIcon;
		iconLibraryClass: FontAwesomeIcons;
		priority: 5;
		iconHeight: 32;
		beReadOnly;
		yourself
]
