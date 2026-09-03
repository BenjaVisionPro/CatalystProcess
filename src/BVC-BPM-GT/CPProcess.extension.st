Extension { #name : 'CPProcess' }

{ #category : '*BVC-BPM-GT' }
CPProcess >> descriptionContainerProcessPresentation: aDescription [
	<magritteContainer>
	^ aDescription
		blocPresentationStencil: [ :aMemento | CPProcessPresentation new ];
		yourself
]
