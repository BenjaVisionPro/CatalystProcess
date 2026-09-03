Extension { #name : 'CPProcessDesign' }

{ #category : '*BVC-BPM-GT' }
CPProcessDesign >> descriptionContainerProcessPresentation: aDescription [
	<magritteContainer>
	^ aDescription
		blocPresentationStencil: [ :aMemento | CPProcessDesignPresentation new ];
		yourself
]
