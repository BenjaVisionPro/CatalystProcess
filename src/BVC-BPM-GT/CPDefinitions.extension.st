Extension { #name : 'CPDefinitions' }

{ #category : '*BVC-BPM-GT' }
CPDefinitions >> descriptionContainerDefinitionsDetail: aDescription [
	<magritteContainer>
	^ aDescription
		blocPresentationStencil: [ :aMemento | CFMaDetailPresentation new ];
		yourself
]
