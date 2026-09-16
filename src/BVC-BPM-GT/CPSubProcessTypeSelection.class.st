Class {
	#name : 'CPSubProcessTypeSelection',
	#superclass : 'CPFlowNodeTypeSelection',
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'type protocol' }
CPSubProcessTypeSelection >> typeClasses [
	^ CPSubProcess subProcessTypes
]

{ #category : 'type protocol' }
CPSubProcessTypeSelection >> typeDescriptionLabel [
	^ 'Sub-process type'
]

{ #category : 'type protocol' }
CPSubProcessTypeSelection >> typeLabelFor: aClass [
	^ aClass subProcessTypeLabel
]

{ #category : 'type protocol' }
CPSubProcessTypeSelection >> typeIconFor: aClass [
	^ aClass subProcessTypeIcon
]


{ #category : 'descriptions' }
CPSubProcessTypeSelection >> typeClassDescription [
	<magritteDescription>
	^ MASingleOptionDescription new
		accessor: #typeClass;
		label: self typeDescriptionLabel;
		options: self typeClasses;
		autoAccept: true;
		fieldConfigure: [ :field |
			field bePopup
				displayBlock: [ :aClass | self typeLabelFor: aClass ] ];
		blocOptionIconStencil: [ :aClass |
			| icon |
			icon := FontAwesomeIcons defaultStyle icon: (self typeIconFor: aClass).
			icon
				size: 14 @ 14;
				addAptitude: (BrLazyStyleCommonAptitude new
					default: [ :aStyle | icon color: (icon theme diagram iconForeground blocResolveColorForTheme: icon theme) ];
					yourself);
				yourself ];
		beRequired;
		yourself
]
