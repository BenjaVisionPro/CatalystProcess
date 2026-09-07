Extension { #name : 'CPBoundaryEvent' }

{ #category : '*BVC-BPM-GT' }
CPBoundaryEvent >> iconDescription [
	<magritteDescription>
	| definitionClass |
	definitionClass := self eventDefinitions
		ifEmpty: [ nil ]
		ifNotEmpty: [ :definitions | definitions first class ].
	^ FontAwesomeIconDescription new
		accessor: #icon;
		label: 'Icon';
		default: (definitionClass
			ifNil: [ self class defaultIcon ]
			ifNotNil: [ definitionClass eventTypeIcon ]);
		iconLibraryClass: FontAwesomeIcons;
		priority: 5;
		iconHeight: 32;
		beReadOnly;
		yourself
]
