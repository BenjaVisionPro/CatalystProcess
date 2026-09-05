Extension { #name : 'CPEndEvent' }

{ #category : '*BVC-BPM-GT' }
CPEndEvent class >> icon [
	^ [ (CPBpmnIcons icon: self defaultIcon) height: 20 ] asStencil
]

{ #category : '*BVC-BPM-GT' }
CPEndEvent >> iconDescription [
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
