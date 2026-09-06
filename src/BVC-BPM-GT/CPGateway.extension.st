Extension { #name : 'CPGateway' }

{ #category : '*BVC-BPM-GT' }
CPGateway >> iconDescription [
	<magritteDescription>
	^ FontAwesomeIconDescription new
		accessor: #icon;
		label: 'Icon';
		default: self class gatewayTypeIcon;
		iconLibraryClass: FontAwesomeIcons;
		priority: 5;
		iconHeight: 32;
		beReadOnly;
		yourself
]
