Extension { #name : 'CPSubProcess' }

{ #category : '*BVC-BPM-GT' }
CPSubProcess class >> icon [
	^ [ (CPBpmnIcons icon: self defaultIcon) height: 20 ] asStencil
]

{ #category : '*BVC-BPM-GT' }
CPSubProcess >> iconDescription [
	<magritteDescription>
	^ FontAwesomeIconDescription new
		accessor: #icon;
		label: 'Icon';
		default: self class subProcessTypeIcon;
		iconLibraryClass: FontAwesomeIcons;
		priority: 5;
		iconHeight: 32;
		beReadOnly;
		cfSerializable: true;
		yourself
]

