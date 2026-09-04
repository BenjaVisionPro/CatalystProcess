Class {
	#name : 'CPProcessLabelAptitude',
	#superclass : 'BrGlamorousEditableLabelAptitude',
	#category : 'BVC-BPM-GT-UI',
	#package : 'BVC-BPM-GT',
	#tag : 'UI'
}

{ #category : 'initialization' }
CPProcessLabelAptitude >> initialize [
	super initialize.
	self glamorousRegularFont.
	self add: (BrLazyStyleCommonAptitude new
		default: [ :aStyle |
			aStyle
				background: Color transparent;
				border: BlBorder empty;
				foreground: (self theme typography titleForeground blocResolveColorForTheme: self theme);
				fontSize: self theme typography titleFontSize ];
		when: BrEditorModeState editable
			style: [ :aStyle |
				aStyle
					background: Color transparent;
					border: BlBorder empty;
					foreground: (self theme typography titleForeground blocResolveColorForTheme: self theme);
					fontSize: self theme typography titleFontSize ];
		hovered: [ :aStyle |
			aStyle
				background: Color transparent;
				border: BlBorder empty ];
		focused: [ :aStyle |
			aStyle
				background: Color transparent;
				border: BlBorder empty;
				foreground: (self theme typography titleForeground blocResolveColorForTheme: self theme) ])
]
